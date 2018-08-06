var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('assessFinanceCharge()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        invcCount  = 0,
        chargeAmt  = 12.34,
        aropen, fincharg
        ;

    it("needs to know the number of invoices at the start", function (done) {
      var sql = "SELECT COUNT(*) AS result FROM invchead;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        invcCount = res.rows[0].result;
        done();
      });
    });

    it("needs an aropen record to work with", function(done) {
      var sql = "SELECT * FROM aropen"                  +
                " WHERE aropen_doctype = 'I'"           +
                "   AND aropen_docnumber NOT IN ("      +
                "       SELECT invchead_invcnumber"     +
                "         FROM invchead"                +
                "         JOIN invcitem ON invchead_id = invcitem_invchead_id" +
                "        WHERE invcitem_descrip ~ '^Finance Charge');"
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">=", 1);
        aropen = res.rows[0];
        console.log(JSON.stringify(aropen));
        done();
      });
    });

    it("needs at least one fincharg record", function (done) {
      var sql = "INSERT INTO fincharg ("                        +
                "  fincharg_mincharg, fincharg_graceperiod,"    +
                "  fincharg_assessoverdue, fincharg_calcfrom,"  +
                "  fincharg_markoninvoice, fincharg_air,"       +
                "  fincharg_accnt_id,"                          +
                "  fincharg_salescat_id"                        +
                ") VALUES ("                                    +
                "  2.56, 64,"                                   +
                "  true, -3,"                                   +
                "  'fincharg_mark', 1.28,"                      +
                "  (SELECT accnt_id FROM accnt LIMIT 1),"       +
                "  (SELECT salescat_id FROM salescat limit 1))" +
                " RETURNING *;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        fincharg = res.rows[0];
        done();
      });
    });

    it.skip("should distinguish among multiple fincharg records");

    it("should fail a non-existent aropen id", function (done) {
      var sql = "SELECT assessFinanceCharge(-5, CURRENT_DATE, 1.23) AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res, 'assessFinanceCharge', -2);
        done();
      });
    });

    it.skip("should fail if the aropen_doctype != 'I'");
    it.skip("should fail if the aropen_docnumber doesn't match an invoice number");

    it("should return 0 for a successful run", function (done) {
      var sql = "SELECT assessFinanceCharge($1, CURRENT_DATE, $2) AS result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ aropen.aropen_id, chargeAmt ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });
    
    it("should have created an invoice", function (done) {
      var sql = "SELECT COUNT(*) AS result FROM invchead;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, invcCount + 1);
        done();
      });
    });

    it("should have created an invoice line", function (done) {
      var sql = "SELECT invcitem_custprice FROM invcitem" +
                " WHERE invcitem_billed = 1.0"            +
                "   AND invcitem_descrip ~* ('Finance Charge .* ' || $1);",
          cred = _.extend({}, adminCred,
                          { parameters: [ aropen.aropen_docnumber ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].invcitem_custprice, chargeAmt);
        done();
      });
    });

    it("should have updated the aropen record", function (done) {
      var sql = "SELECT aropen_fincharg_date, aropen_fincharg_amount" +
                "  FROM aropen WHERE aropen_id = $1;",
          cred = _.extend({}, adminCred,
                          { parameters: [ aropen.aropen_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].aropen_fincharg_amount, chargeAmt);
        done();
      });
    });

    it.skip("should have enforced fincharg_mincharg");

    it("should return 0 for a second run", function (done) {
      var sql = "SELECT assessFinanceCharge($1, CURRENT_DATE, $2) AS result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ aropen.aropen_id, chargeAmt ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });

    it("should have updated the aropen record again", function (done) {
      var sql = "SELECT aropen_fincharg_date, aropen_fincharg_amount" +
                "  FROM aropen WHERE aropen_id = $1;",
          cred = _.extend({}, adminCred,
                          { parameters: [ aropen.aropen_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].aropen_fincharg_amount, chargeAmt * 2);
        done();
      });
    });

  });

}());
