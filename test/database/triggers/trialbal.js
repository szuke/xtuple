var _      = require("underscore"),
    assert = require("chai").assert,
    dblib  = require("../dblib");

(function () {
  'use strict';

  describe("trialbal trigger test", function () {
    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        accountid   = 109, /* this is the EBank bank G/L account */
        yearid     = -1,
        periodid   = -1
    ;

    it("should create a new fiscal Year", function (done) {
      var sql = "SELECT createAccountingYearPeriod((SELECT yearperiod_end + 1 FROM yearperiod " +
                                   "ORDER BY yearperiod_end DESC LIMIT 1), " +
                                   "((SELECT yearperiod_end + 1 FROM yearperiod " +
                                   "ORDER BY yearperiod_end DESC LIMIT 1) + '365 days'::INTERVAL)::DATE) AS year_id;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.equal(res.rowCount, 1, "expected one year to be created");
        yearid = res.rows[0].year_id;
        assert.isTrue(yearid >= 0, "expected a fiscal yearperiod id");
        done();
      });
    });

    it("should create a new fiscal period in the new fiscal year", function (done) {
      var sql = "SELECT createAccountingPeriod(yearperiod_start, " +
                "(yearperiod_start + '1 mon'::interval)::date, $1, 1) AS period_id " +
                "FROM yearperiod WHERE (yearperiod_id=$1);",
          admin = _.extend({}, adminCred, { parameters: [ yearid ] });
      datasource.query(sql, admin, function (err, res) {
        assert.equal(res.rowCount, 1, "expected one period to be created");
        periodid = res.rows[0].period_id;
        assert.isTrue(periodid >= 0, "expected a fiscal period id");
        done();
      });
    });

    it("should create trialbal records for new fiscal period", function (done) {
      var sql = "SELECT count(*) AS trialbal FROM trialbal WHERE trialbal_period_id=$1;",
          reccount = -1,
          admin = _.extend({}, adminCred, { parameters: [ periodid ] });
      datasource.query(sql, admin, function (err, res) {
        reccount = res.rows[0].trialbal;
        assert.isTrue(periodid >= 0, "expected a trial balance records to be created");
        done();
      });
    });

    it("should prevent deletion of trialbal record from closed period", function (done) {
      var sql = "DELETE FROM trialbal WHERE trialbal_period_id= " +
            "(select period_id from period where period_closed order by period_end DESC LIMIT 1);";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNotNull(err, "expect an error deleting a trialbal record in a closed period");
        assert.isTrue(String(err).indexOf("closed periods") > 0);
        done();
      });
    });

    it("should prevent editing of trialbal record in closed period", function (done) {
      var sql = "UPDATE trialbal SET trialbal_debits=trialbal_debits + 100, trialbal_ending=trialbal_ending - 100 " +
            "WHERE (trialbal_accnt_id=$1) AND (trialbal_period_id= " +
            "(select period_id from period where period_closed order by period_end DESC LIMIT 1));",
          admin = _.extend({}, adminCred, { parameters: [ accountid ] });
      datasource.query(sql, admin, function (err, res) {
        assert.isNotNull(err, "expect an error editing a trialbal record in a closed period");
        assert.isTrue(String(err).indexOf("closed Period") > 0);
        done();
      });
    });


    it("should allow editing of trialbal record in open period", function (done) {
      var sql = "SELECT forwardupdatetrialbalance(trialbal_id) FROM trialbal " +
                "WHERE ((trialbal_period_id = $1) " +
                "AND (trialbal_accnt_id = $2));",
          admin = _.extend({}, adminCred, { parameters: [ periodid, accountid ] });
      datasource.query(sql, admin, function (err, res) {
        assert.isNull(err, "expected no error when editing a trialbal record in an open period");
        done();
      });
    });

    it("should allow deletion of newly created fiscal period", function (done) {
      var sql = "SELECT deleteAccountingPeriod($1) AS result;",
          admin = _.extend({}, adminCred, { parameters: [ periodid ] });
      datasource.query(sql, admin, function (err, res) {
        assert.isNull(err, "expected no error when deleting fiscal period");
        done();
      });
    });

    it("should allow deletion of newly created fiscal year", function (done) {
      var sql = "SELECT deleteAccountingYearPeriod($1) AS result;",
          admin = _.extend({}, adminCred, { parameters: [ yearid ] });
      datasource.query(sql, admin, function (err, res) {
        assert.isNull(err, "expected no error when deleting fiscal year");
        done();
      });
    });

  });
})();
