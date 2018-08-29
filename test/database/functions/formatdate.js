var assert = require("chai").assert;
var dblib  = require("../dblib");

(function () {
  "use strict";

  describe("formatDate()", function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds()
        ;

    it("should accept a date", function (done) {
      var sql = "select formatDate(current_date) AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.closeTo((new Date(res.rows[0].result)).valueOf(),
                       (new Date()).valueOf(),
                       1000 * 60 * 60 * 24);
        done();
      });
    });

    it("should accept a timestamp with time zone", function (done) {
      var sql = "select formatDate(current_timestamp) AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.closeTo((new Date(res.rows[0].result)).valueOf(),
                       (new Date()).valueOf(),
                       1000 * 60 * 60 * 24);
        done();
      });
    });

    it("should return its second arg if given a null date", function (done) {
      var sql = "select formatDate(NULL, 'nulldate') AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 'nulldate');
        done();
      });
    });

    it("should return its second arg if given start of time", function (done) {
      var sql = "select formatDate(startOfTime(), 'sot') AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 'sot');
        done();
      });
    });

    it("should return its second arg if given end of time", function (done) {
      var sql = "select formatDate(endOfTime(), 'eot') AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 'eot');
        done();
      });
    });

  });

})();
