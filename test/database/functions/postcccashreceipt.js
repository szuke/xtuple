var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe.skip('postCCCashReceipt()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        sql        = "select postCCCashReceipt($1, $2, $3, $4) as result;",
        cashrcpt, ccard, ccpay, cohead, metric
        ;

    it("needs to get metrics", function (done) {
      var sql = "select fetchMetricBool('EnableCustomerDeposits')" +
                "    as EnableCustomerDeposits;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        metric = res.row[0];
        done();
      });
    });

    it("should fail with no ccpay", function (done) {
      var cred = _.extend({}, adminCred,
                  { parameters: [ -1, 15, 'cashrcpt', 123.45 ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, 'postCCcashReceipt', -11);
        assert.isUndefined(res);
        done();
      });
    });

    it("needs an active ccard", function (done) {
      var sql = "select * from ccard where ccard_active limit 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNotNull(err);
        assert.equal(res.rowCount, 1);
        ccard = res.rows[0];
        done();
      });
    });

    it("needs a ccpay", function (done) {
      var sql = "insert into ccpay ("                                   +
                "  ccpay_ccard_id, ccpay_cust_id,  ccpay_amount,"       +
                "  ccpay_status,   ccpay_type,     ccpay_auth_charge"   +
                ") values"                              +
                "  ($1, $2, 123.45, 'A', 'C', 'C'),"    +
                "  ($1, $2, 234.56, 'A', 'C', 'C'),"    +
                "  ($1, $2, 345.67, 'A', 'C', 'C'),"    +
                "  ($1, $2, 456.78, 'A', 'C', 'C'),"    +
                "  ($1, $2, 567.89, 'A', 'C', 'C'),"    +
                "  ($1, $2, 678.90, 'A', 'C', 'C'),"    +
                "  ($1, $2, 789.10, 'A', 'C', 'C'),"    +
                "  ($1, $2, 890.12, 'A', 'C', 'C');";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNotNull(err);
        assert.equal(res.rowCount, 1);
        ccpay = res.rows[0];
        done();
      });
    });

    it.skip("needs a sales order to test with");

    it("set EnableCustomerDeposits false", function (done) {
      var sql = "select setMetric('EnableCustomerDeposits', 'f') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should succeed for cashrcpt w/o a docid", function (done) {
      var amt = 234.56,
          id  = _.find(ccpay, function(e) { return e.ccpay_amount === amt; }),
          cred = _.extend({}, adminCred,
                  { parameters: [ id.ccpay_id, null, 'cashrcpt', amt ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });

    it.skip("should have created a cashrcpt record");
    it.skip("should have touched the GL");

    it("should succeed for cashrcpt w/ a docid", function (done) {
      var amt  = 345.67,
          id   = _.find(ccpay, function(e) { return e.ccpay_amount === amt; }),
          cred = _.extend({}, adminCred,
                  { parameters: [ id.ccpay_id, cashrcpt.cashrcpt_id, 'cashrcpt', amt ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });
    it.skip("should have touched the GL");

    it.skip("should fail for cohead w/o a docid", function (done) {
      var amt  = 456.78,
          id   = _.find(ccpay, function(e) { return e.ccpay_amount === amt; }),
          cred = _.extend({}, adminCred,
                  { parameters: [ id.ccpay_id, null, 'cohead', amt ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res);
        assert.isUndefined(res);
        done();
      });
    });

    it.skip("should succeed for cohead w/ a docid", function (done) {
      var amt  = 567.89,
          id   = _.find(ccpay, function(e) { return e.ccpay_amount === amt; }),
          cred = _.extend({}, adminCred,
                  { parameters: [ id.ccpay_id, cohead.cohead_id, 'cohead', amt ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });

    it.skip("should have called createARCashDeposit");
    it.skip("should have touched the GL");

    it.skip("set EnableCustomerDeposits true");

    it("should succeed for cashrcpt with EnableCustomerDeposits", function (done) {
      var amt  = 678.90,
          id   = _.find(ccpay, function(e) { return e.ccpay_amount === amt; }),
          cred = _.extend({}, adminCred,
                  { parameters: [ id.ccpay_id, null, 'cashrcpt', amt ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });
    it.skip("should have touched the GL");

    it.skip("should fail for cohead w/o id and EnableCustomerDeposits", function (done) {
      var cred = _.extend({}, adminCred,
                  { parameters: [ ccpay.ccpay_id, null, 'cohead', 789.01 ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res);
        assert.isUndefined(res);
        done();
      });
    });

    it("should succeed for cohead w/ id and EnableCustomerDeposits", function (done) {
      var amt  = 890.12,
          id   = _.find(ccpay, function(e) { return e.ccpay_amount === amt; }),
          cred = _.extend({}, adminCred,
                  { parameters: [ id.ccpay_id, cohead.cohead_id, 'cohead', amt ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });

    it.skip("should have called createARCreditMemo");
    it.skip("should have touched the GL");

    it.skip("reset metrics");

  });

}());
