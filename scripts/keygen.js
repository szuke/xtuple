#!/usr/bin/env node
/* jshint node:true, esversion:6 */
(function () {
  'use strict';
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
  let DataSource = function () {
    this.dataSource = require('../node-datasource/lib/ext/datasource').dataSource;
    this.credentials = require(script.config).databaseServer;
    this.credentials.database = script.database;
    /**
     * @param {Query} query
     * @return {Promise}
     */
    this.execute = function (query) {
      return new Promise((resolve, reject) => {
        this.dataSource.query(
          query.sql(),
          Object.assign(this.credentials, {
            parameters: query.parameters()
          }),
          function (error, result) {
            if (error) {
              reject(error);
            }
            resolve(result);
          }
        );
      });
    };
  };

  /**
   * @constructor
   * @param {(string|string[])} query
   * @param {Array.<string>}    parameters
   */
  let Query = function (query, parameters) {
    /**
     * @returns {string}
     */
    this.sql = function () {
      if (Array.isArray(query)) {
        query = query.join(' ');
      }
      return query;
    };
    /**
     * @returns {Array.<string>}
     */
    this.parameters = function () {
      return parameters;
    };
  };

  /** @type {{psi: Object, asn1: Object, pkcs12: Object}} */
  let forge = require('node-forge');
  let filesystem = require('fs');
  let Promises = {
    createKeypair: function (resolve, reject) {
      forge.pki.rsa.generateKeyPair(2048, 65537, null, (error, keypair) => {
        if (error) {
          reject(error);
        }
        resolve(keypair);
      });
    },
    readOAuth2ClientSQLFile: function (resolve, reject) {
      filesystem.readFile(
        '{directory}/sql/oauth2client.sql'.replace('{directory}', __dirname),
        'utf8',
        (error, content) => {
          if (error) {
            reject(error);
          }
          resolve(content);
        }
      );
    },
    saveP12File: function (privateKey) {
      return (resolve, reject) => {
        filesystem.writeFile(script.path, new Buffer(new Buffer(
          forge.asn1.toDer(
            forge.pkcs12.toPkcs12Asn1(privateKey, null, 'notasecret')
          ).getBytes(),
          'binary'
        ), 'base64'), (error, result) => {
          if (error) {
            reject(error);
          }
          resolve(result);
        });
      };
    }
  };

  let erp = new DataSource();
  Promise
    .all([
      new Promise(Promises.createKeypair),
      new Promise(Promises.readOAuth2ClientSQLFile)
    ])
    .then((results) => {
      let keypair = results[0];
      let sql = results[1];
      return Promise.all([
        erp.execute(new Query(sql, [
          script.iss,
          script.iss,
          forge.pki.publicKeyToPem(keypair.publicKey)
        ])),
        new Promise(Promises.saveP12File(keypair.privateKey))
      ]);
    })
    .then(() => {
      return erp.execute(new Query([
        "INSERT INTO xdruple.xd_site (xd_site_name, xd_site_url)",
        "VALUES ($1, $2)",
        "ON CONFLICT (xd_site_name) DO UPDATE",
        "SET xd_site_name = $1, xd_site_url = $2"
      ], [
        script.application,
        script.application
      ]));
    })
    .catch((error) => {
      console.log(error);
    });
}());
