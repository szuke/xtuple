var _      = require("underscore"),
    assert = require('chai').assert;

(function () {
  "use strict";
  describe('createFiscalYear()', function () {

    var loginData = require("../../lib/login_data.js").data,
      datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
      config = require("../../../node-datasource/config.js"),
      creds = _.extend({}, config.databaseServer, {database: loginData.org}),
      yp = {};

    function addYears(aDate, anInt) {
      var newDate = new Date(aDate.getFullYear() + anInt,
                             aDate.getMonth(), aDate.getDate());
      return newDate;
    }

    it("needs to know if a fiscal year already exists", function (done) {
      var sql = "select yearperiod_id from yearperiod" +
                " where current_date between yearperiod_start and yearperiod_end;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        if (res.rowCount === 1) {
          yp.current_id = res.rows[0].yearperiod_id;
        } else {
          assert.equal(res.rowCount, 0, "expect 0 or 1 current fiscal year");
        }
        done();
      });
    });

    it("should create a fiscal year if necessary with no args", function (done) {
      var sql = "select createFiscalYear() as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        if ("current_id" in yp) {
          assert.equal(yp.current_id, res.rows[0].result, "current YP");
        } else {
          yp.current_id = res.rows[0].result;
          assert.operator(yp.current_id, ">", 0, "new YP");
        }
        done();
      });
    });

    it("needs test to delete the current FY to test NULL & 'M'", function (done) {
      var sql = "select deleteAccountingYearPeriod($1) as result;",
          tmpCred = _.extend({}, creds, { parameters: [ yp.current_id ] });
      datasource.query(sql, tmpCred, function (err, res) {
        if (err) {
          assert.match(err, /-4/, "can't test NULL/'M' - periods are in use:-(");
        } else {
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].result, ">=", 0);
        }
        done();
      });
    });

    it("should create a new fiscal year with NULL & 'M'", function (done) {
      var sql = "select createFiscalYear(NULL, 'M') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        yp.current_id = res.rows[0].result;
        assert.operator(yp.current_id, ">", 0, "new YP");
        done();
      });
    });

    it("should have created 12 months with NULL & 'M'", function (done) {
      var sql = "select * from period" +
                " where period_yearperiod_id = $1 order by period_start;",
          tmpCred = _.extend({}, creds, { parameters: [ yp.current_id ] });
      datasource.query(sql, tmpCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 12);
        _.each(res.rows, function (e, i) {
          assert.closeTo(e.period_quarter, (i / 4) + 1, 0.8);
        });
        done();
      });
    });

    it("needs the last existing yearperiod", function (done) {
      var sql = "select max(yearperiod_start) as max from yearperiod;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        yp.last_start = res.rows[0].max;
        done();
      });
    });

    it("should create a new fiscal year with one arg", function (done) {
      var sql = "select createFiscalYear($1) as result;",
          tmpCred = _.extend({}, creds, { parameters: [ addYears(yp.last_start, 1) ] });
      datasource.query(sql, tmpCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        yp.newOne_id = res.rows[0].result;
        assert.operator(yp.newOne_id, ">", 0);
        done();
      });
    });

    it("should have created 12 months with one arg", function (done) {
      var sql = "select * from period" +
                " where period_yearperiod_id = $1 order by period_start;",
          tmpCred = _.extend({}, creds, { parameters: [ yp.newOne_id ] });
      datasource.query(sql, tmpCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 12);
        _.each(res.rows, function (e, i) {
          assert.closeTo(e.period_quarter, (i / 4) + 1, 0.8);
        });
        done();
      });
    });

    it("should create a new fiscal year with date & 'M'", function (done) {
      var sql = "select createFiscalYear($1, 'M') as result;",
          tmpCred = _.extend({}, creds, { parameters: [ addYears(yp.last_start, 2) ] });
      datasource.query(sql, tmpCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        yp.newM_id = res.rows[0].result;
        assert.operator(yp.newM_id, ">", 0);
        done();
      });
    });

    it("should have created 12 months with date & 'M'", function (done) {
      var sql = "select * from period" +
                " where period_yearperiod_id = $1 order by period_start;",
          tmpCred = _.extend({}, creds, { parameters: [ yp.newM_id ] });
      datasource.query(sql, tmpCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 12);
        _.each(res.rows, function (e, i) {
          assert.closeTo(e.period_quarter, (i / 4) + 1, 0.8);
        });
        done();
      });
    });

    it("should create a new fiscal year with date & 'Q'", function (done) {
      var sql = "select createFiscalYear($1, 'Q') as result;",
          tmpCred = _.extend({}, creds, { parameters: [ addYears(yp.last_start, 3) ] });
      datasource.query(sql, tmpCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        yp.newQ_id = res.rows[0].result;
        assert.operator(yp.newQ_id, ">", 0);
        done();
      });
    });

    it("should have created 4 quarters with date & 'Q'", function (done) {
      var sql = "select * from period" +
                " where period_yearperiod_id = $1 order by period_start;",
          tmpCred = _.extend({}, creds, { parameters: [ yp.newQ_id ] });
      datasource.query(sql, tmpCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 4);
        _.each(res.rows, function (e, i) {
          assert.equal(e.period_quarter, i + 1);
        });
        done();
      });
    });

    it("should fail with an unknown style", function (done) {
      var sql = "select createFiscalYear($1, 'UnKnOwN') as result;",
          tmpCred = _.extend({}, creds, { parameters: [ addYears(yp.last_start, 4)] });
      datasource.query(sql, tmpCred, function (err, res) {
        assert.isNotNull(err);
        assert.isUndefined(res);
        done();
      });
    });

    it("should succeed if the yp and periods exist as requested", function (done) {
      // this was created above if it didn't already exist
      var sql = "select createFiscalYear() as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(yp.current_id, res.rows[0].result);
        done();
      });
    });

  });
})();
