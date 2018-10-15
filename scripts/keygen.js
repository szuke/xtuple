#!/usr/bin/env node
/* jshint node:true, esversion:6 */
(function () {
  'use strict';
  let forge = require('node-forge');
  let fs = require('fs');

  let script = require('commander')
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
     * @return {Promise}
     */
    this.execute = function (query) {
      return new Promise((resolve, reject) => {
        this.dataSource.query(query.sql(), this.credentials, function (error, result) {
          if (error) {
            reject(error);
          }
          resolve(result);
        });
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
      for (let parameter in parameters) {
        if (parameters.hasOwnProperty(parameter)) {
          query = query.replace(
            new RegExp(
              '{{ parameter }}'.replace('parameter', parameter),
              'g'
            ),
            parameters[parameter]
          );
        }
      }
      return query;
    };
  }

  let erp = new DataSource();

  Promise.resolve()
    .then(() => {
      return new Promise((resolve, reject) => {
        forge.pki.rsa.generateKeyPair(2048, 65537, null, (error, keypair) => {
          if (error) {
            reject(error);
          }
          resolve(keypair);
        });
      });
    })
    .then((keypair) => {
      Promise.resolve()
        .then(() => {
          return new Promise((resolve, reject) => {
            fs.readFile(
              '{directory}/sql/oauth2client.sql'.replace('{directory}', __dirname),
              'utf8',
              (error, content) => {
                if (error) {
                  reject(error);
                }
                resolve(content);
              }
            );
          });
        })
        .then((content) => {
          return erp.execute(new Query(content, {
            id: script.iss,
            client: script.iss,
            key: forge.pki.publicKeyToPem(keypair.publicKey)
          }));
        })
        .then(() => {
          return new Promise((resolve, reject) => {
            fs.writeFile(script.path, new Buffer(new Buffer(
              forge.asn1.toDer(
                forge.pkcs12.toPkcs12Asn1(keypair.privateKey, null, 'notasecret')
              ).getBytes(),
              'binary'
            ), 'base64'), (error, result) => {
              if (error) {
                reject(error);
              }
              resolve(result);
            });
          });
        })
        .catch((error) => {
          throw error;
        });
    })
    .then(() => {
      return erp.execute(new Query([
        "INSERT INTO xdruple.xd_site (xd_site_name, xd_site_url)",
        "VALUES ('{{ name }}', '{{ url }}')",
        "ON CONFLICT (xd_site_name) DO UPDATE",
        "SET xd_site_name = '{{ name }}', xd_site_url='{{ url }}'"
      ], {
        name: script.application,
        url: script.application
      }));
    })
    .catch((error) => {
      console.log(error);
    });
}());
