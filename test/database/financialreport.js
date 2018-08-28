var _ = require("underscore"),
  assert = require('chai').assert;

(function () {
  "use strict";

  describe('financialReport()', function () {

    var loginData = require("../lib/login_data.js").data,
      datasource = require('../../node-datasource/lib/ext/datasource').dataSource,
      config     = require("../../node-datasource/config.js"),
      creds = _.extend({}, config.databaseServer, {database: loginData.org}),
      oldval    = -98.76,       // makes it easy to spot in test failures
      changeval = 123.45,
      freSql = "select financialreport(flhead_id, period_id, 'M', -1) as fr"   +
               "  from flhead, period"                                         +
               " where flhead_name = 'Basic Balance Sheet'"                    +
               "   and current_date between period_start and period_end;",
      valueSql = " select cast(sum(flrpt_ending) as text) as value"            +
                 "   from flrpt"                                               +
                 "   join accnt on flrpt_accnt_id = accnt_id"                  +
                 " where accnt_descrip = 'Cash at eBank'"                      +
                 ";"
      ;
    this.timeout(10*1000);      // the fre ain't speedy

    it("needs a fiscal year", function (done) {
      var sql = "select createFiscalYear(NULL, 'M') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err, 'no exception from creating periods');
        done();
      });
    });

    it("should generate financial report data", function (done) {
      datasource.query(freSql, creds, function (err, res) {
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].fr);
        done();
      });
    });

    it("should get the starting net asset value", function (done) {
      datasource.query(valueSql, creds, function (err, res) {
        assert.equal(res.rowCount, 1);
        oldval = Number(res.rows[0].value);
        done();
      });
    });

    it("should insert a gl transaction", function (done) {
      var sql = "select insertgltransaction('G/L', 'ST', 'FREtest',"       +
                "  'testing financialreport()', cr.accnt_id, dr.accnt_id," +
                "  -1, $1, period_end) AS result"                          +
                "  from accnt cr, accnt dr, period"                        +
                " where cr.accnt_descrip = 'Cash at eBank'"                +
                "   and dr.accnt_descrip = 'Deferred Revenue'"             +
                "   and current_date between period_start and period_end;",
          cred = _.extend({}, creds, { parameters: [ changeval ] });
      datasource.query(sql, cred, function (err, res) {
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].result > 0);
        done();
      });
    });

    it("should regenerate financial report data", function (done) {
      datasource.query(freSql, creds, function (err, res) {
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].fr);
        done();
      });
    });

    it("should show a net asset value change", function (done) {
      datasource.query(valueSql, creds, function (err, res) {
        assert.equal(res.rowCount, 1);
        var newval = Number(res.rows[0].value);
        assert.closeTo(oldval - newval, changeval, 0.001);
        done();
      });
    });

  });
}());



