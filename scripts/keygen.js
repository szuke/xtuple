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
  var credentials = require(script.config).databaseServer;
  credentials.database = script.database;

  forge.pki.rsa.generateKeyPair(2048, 65537, null, function (error, keypair) {
    if (error) {
      throw error;
    }
    var dataSource = require('../node-datasource/lib/ext/datasource').dataSource;
    fs.readFile(
      '{directory}/sql/oauth2client.sql'.replace('{directory}', __dirname),
      'utf8',
      function (error, content) {
        /** @var string content */
        if (error) {
          throw error;
        }
        dataSource.query(
          "DELETE FROM xt.oa2client WHERE oa2client_client_id = '{id}'"
            .replace('{id}', script.database),
          credentials,
          function (error) {
            if (error) {
              throw error;
            }
            dataSource.query(
              content
                .replace('{id}', script.iss)
                .replace('{client}', script.iss)
                .replace('{public_key}', forge.pki.publicKeyToPem(keypair.publicKey))
                .replace('{organization}', script.database),
              credentials,
              function (error) {
                if (error) {
                  throw error;
                }
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
          }
        );
      }
    );
    fs.readFile(
      '{directory}/sql/application.sql'.replace('{directory}', __dirname),
      'utf8',
      function (error, content) {
        /** @var string content */
        if (error) {
          throw error;
        }
        dataSource.query(
          "DELETE FROM xdruple.xd_site WHERE xd_site_name = '{name}'"
            .replace('{name}', script.application),
          credentials,
          function (error) {
            if (error) {
              throw error;
            }
            dataSource.query(
              content
                .replace('{name}', script.application)
                .replace('{url}', script.application),
              credentials,
              function (error) {
                if (error) {
                  throw error;
                }
              }
            );
          }
        );
      }
    );
  });
}());
