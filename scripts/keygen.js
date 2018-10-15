#!/usr/bin/env node
/*jshint node:true */
(function () {
  'use strict';
  var forge = require('node-forge');
  var fs = require('fs');

  var script = require('commander')
    .option('-c, --config </path/to/file>', 'Location of the config file.')
    .option('-d, --database <name>', 'Database name')
    .option('-i, --iss <issuer>', 'Issuer ID (ISS)')
    .option('-p, --path </path/to/p12/output>', 'Path to p12 file output')
    .option('-a, --application <name>', 'Application (xDruple site name)')
    .parse(process.argv);

  /**
   * @constructor
   */
  function DataSource() {
    this.dataSource = require('../node-datasource/lib/ext/datasource').dataSource;
    this.credentials = require(script.config).databaseServer;
    this.credentials.database = script.database;
    /**
     * @param {Query} query
     * @param {?Function} [success=null]
     */
    this.execute = function (query, success) {
      this.dataSource.query(query.sql(), this.credentials, function (error) {
        if (error) {
          throw error;
        }
        if (success) {
          success();
        }
      });
    };
  }

  /**
   * @constructor
   * @param {(string|string[])}      query
   * @param {Object.<string,string>} parameters
   */
  function Query(query, parameters) {
    /**
     * @returns {string}
     */
    this.sql = function () {
      if (Array.isArray(query)) {
        query = query.join(' ');
      }
      for (var parameter in parameters) {
        if (parameters.hasOwnProperty(parameter)) {
          query = query.replace(
            '{{ parameter }}'.replace('parameter', parameter),
            parameters[parameter]
          );
        }
      }
      return query;
    };
  }

  forge.pki.rsa.generateKeyPair(2048, 65537, null, function (error, keypair) {
    if (error) {
      throw error;
    }
    var erp = new DataSource();
    fs.readFile(
      '{directory}/sql/oauth2client.sql'.replace('{directory}', __dirname),
      'utf8',
      function (error, content) {
        /** @var string content */
        if (error) {
          throw error;
        }
        erp.execute(new Query(
          "DELETE FROM xt.oa2client WHERE oa2client_client_id = '{{ id }}'",
          {
            id: script.database
          }
        ), function () {
          erp.execute(new Query(content, {
              id: script.iss,
              client: script.iss,
              key: forge.pki.publicKeyToPem(keypair.publicKey)
            }), function () {
              fs.writeFile(script.path, new Buffer(new Buffer(
                forge.asn1.toDer(
                  forge.pkcs12.toPkcs12Asn1(keypair.privateKey, null, 'notasecret')
                ).getBytes(),
                'binary'
              ), 'base64'), function (error) {
                if (error) {
                  throw error;
                }
              });
            }
          );
        });
      }
    );
    erp.execute(new Query(
      "DELETE FROM xdruple.xd_site WHERE xd_site_name = '{{ name }}'",
      {
        name: script.application
      }
    ), function () {
      erp.execute(new Query([
        "INSERT INTO xdruple.xd_site (xd_site_name, xd_site_url)",
        "VALUES ('{{ name }}', '{{ url }}');"
      ], {
        name: script.application,
        url: script.application
      }));
    });
  });
}());
