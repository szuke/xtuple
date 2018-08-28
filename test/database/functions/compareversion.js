var _ = require("underscore"),
  assert = require('chai').assert,
  path = require('path');

(function () {
  "use strict";
  describe('compareVersion()', function () {

    var loginData = require(path.join(__dirname, "../../lib/login_data.js")).data,
      datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
      config = require(path.join(__dirname, "../../../node-datasource/config.js")),
      creds = _.extend({}, config.databaseServer, {database: loginData.org});

    it("should return negative for PG version older than current", function (done) {
      var sql = "select compareVersion('7.0') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].result, -1);
        done();
      });
    });

    it("should return positive for PG version newer than current", function (done) {
      var sql = "select compareVersion('15.0') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].result, 1);
        done();
      });
    });

    it("should return negative for PG version older than current", function (done) {
      var sql = "select compareVersion('7.0') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].result, -1);
        done();
      });
    });

    it("should compare 2 major version numbers", function (done) {
      var sql = "select compareVersion('4.5.5', '5.5.7') as lt," +
                "       compareVersion('4.5.6', '4.5.6') as eq," +
                "       compareVersion('5.5.7', '4.5.5') as gt;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].lt, -1);
        assert.equal(res.rows[0].eq,  0);
        assert.equal(res.rows[0].gt,  1);
        done();
      });
    });

    it("should compare 2 minor version numbers", function (done) {
      var sql = "select compareVersion('4.5.5', '4.6.7') as lt," +
                "       compareVersion('4.5.6', '4.5.6') as eq," +
                "       compareVersion('4.6.7', '4.5.5') as gt;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].lt, -1);
        assert.equal(res.rows[0].eq,  0);
        assert.equal(res.rows[0].gt,  1);
        done();
      });
    });

    it("should compare 2 point version numbers", function (done) {
      var sql = "select compareVersion('4.5.5', '4.5.7') as lt," +
                "       compareVersion('4.5.6', '4.5.6') as eq," +
                "       compareVersion('4.5.7', '4.5.5') as gt;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].lt, -1);
        assert.equal(res.rows[0].eq,  0);
        assert.equal(res.rows[0].gt,  1);
        done();
      });
    });

    it("should handle transition from 1 to 2 digit numbers", function (done) {
      var sql = "select compareVersion('4.9.5',  '4.10.7') as lt," +
                "       compareVersion('4.10.7', '4.9.5')  as gt;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].lt, -1);
        assert.equal(res.rows[0].gt,  1);
        done();
      });
    });

    it("should handle xTuple-style", function (done) {
      var sql = "select compareVersion('4.5.5Alpha',  '4.5.7Alpha2') as lt1," +
                "       compareVersion('4.5.6Alpha2', '4.5.6Beta')   as lt2," +
                "       compareVersion('4.5.6Beta',   '4.5.6Beta2')  as lt3," +
                "       compareVersion('4.5.6Beta2',  '4.5.6RC')     as lt4," +
                "       compareVersion('4.5.6RC',     '4.5.6')       as lt5," +
                "       compareVersion('4.5.6',       '4.5.7')       as lt6 " +
                "       ;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].lt1, -1, "alpha vs. alpha2");
        assert.equal(res.rows[0].lt2, -1, "alpha2 vs. beta");
        assert.equal(res.rows[0].lt3, -1, "beta vs. beta2");
        assert.equal(res.rows[0].lt4, -1, "beta2 vs. rc");
        assert.equal(res.rows[0].lt5, -1, "rc vs. final");
        assert.equal(res.rows[0].lt6, -1, "final vs. next final");
        done();
      });
    });

    it("should handle semver", function (done) {
      var sql = "select compareVersion('4.5.5-alpha',   '4.5.7-alpha.2') as lt1," +
                "       compareVersion('4.5.6-alpha.2', '4.5.6-beta')    as lt2," +
                "       compareVersion('4.5.6-beta',    '4.5.6-beta.2')  as lt3," +
                "       compareVersion('4.5.6-beta.2',  '4.5.6-RC')      as lt4," +
                "       compareVersion('4.5.6-RC',      '4.5.6')         as lt5," +
                "       compareVersion('4.5.6',         '4.5.7')         as lt6 " +
                "       ;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].lt1, -1, "alpha vs. alpha2");
        assert.equal(res.rows[0].lt2, -1, "alpha2 vs. beta");
        assert.equal(res.rows[0].lt3, -1, "beta vs. beta2");
        assert.equal(res.rows[0].lt4, -1, "beta2 vs. rc");
        assert.equal(res.rows[0].lt5, -1, "rc vs. final");
        assert.equal(res.rows[0].lt6, -1, "final vs. next final");
        done();
      });
    });


  });
}());
