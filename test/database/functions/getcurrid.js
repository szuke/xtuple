var assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  'use strict';

  describe('getcurrid()', function () {
    var adminCred   = dblib.adminCred,
        datasource  = dblib.datasource;

    it("should return null for null currency", function (done) {
      var sql = "select getCurrId(NULL) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isNull(res.rows[0].result);
        done();
      });
    });

    it("should fail if bad currency", function (done) {
      var sql = "select getCurrId('ABC') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res, 'getCurrId', -1);
        done();
      });
    });

    it("should succeed for valid currency", function (done) {
      var sql = "select getCurrId('USD') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

  });
}());
