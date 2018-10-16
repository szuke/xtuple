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
   * @param {Function} resolve
   * @param {Function} reject
   * @returns {Function}
   */
  let resolver = function (resolve, reject) {
    return (error, result) => {
      if (error) {
        reject(error);
      }
      resolve(result);
    };
  };

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
          resolver(resolve, reject)
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
  let promises = {
    /**
     * @returns {Promise}
     */
    generateRSAKeyPair: function (bits, exponent) {
      return new Promise((resolve, reject) => {
        forge.pki.rsa.generateKeyPair(bits, exponent, null, resolver(resolve, reject));
      });
    },
    /**
     * @param {string} path
     * @returns {Promise}
     */
    readFile: function (path) {
      return new Promise((resolve, reject) => {
        filesystem.readFile(path, 'utf8', resolver(resolve, reject));
      });
    },
    /**
     * @param {string} path
     * @param {Buffer} data
     * @returns {Promise}
     */
    writeFile: function (path, data) {
      return new Promise((resolve, reject) => {
        filesystem.writeFile(path, data, resolver(resolve, reject));
      });
    }
  };

  let erp = new DataSource();
  Promise
    .all([
      promises.generateRSAKeyPair(2048, 65537),
      promises.readFile(
        '{{ directory }}/sql/oauth2client.sql'.replace('{{ directory }}', __dirname)
      )
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
        promises.writeFile(
          script.path,
          new Buffer(
            new Buffer(
              forge.asn1.toDer(
                forge.pkcs12.toPkcs12Asn1(keypair.privateKey, null, 'notasecret')
              ).getBytes(),
              'binary'
            ),
            'base64'
          )
        )
      ]);
    })
    .then(() => {
      return erp.execute(new Query([
        'INSERT INTO xdruple.xd_site (xd_site_name, xd_site_url)',
        'VALUES ($1, $2)',
        'ON CONFLICT (xd_site_name) DO UPDATE',
        'SET xd_site_name = $1, xd_site_url = $2'
      ], [
        script.application,
        script.application
      ]));
    })
    .catch((error) => {
      console.log(error);
    });
}());
