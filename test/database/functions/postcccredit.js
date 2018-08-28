var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('postCCCredit()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        id         = {};

    it("should fail for unknown sales order", function (done) {
      var sql = "select postCCCredit(-15, 'cohead', -15) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res, "postCCcredit", -2);
        done();
      });
    });

    it("should fail for unknown A/R Open record", function (done) {
      var sql = "select postCCCredit(-15, 'aropen', -15) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res, "postCCcredit", -2);
        done();
      });
    });

    it("should fail for unknown credit memo", function (done) {
      var sql = "select postCCCredit(-15, 'cmhead', -15) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res, "postCCcredit", -2);
        done();
      });
    });

    it("should fail for unknown document type", function (done) {
      var sql = "select postCCCredit(-15, 'unknown', -15) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res, "postCCcredit");
        done();
      });
    });

    it("should fail for non-existent credit card transaction", function (done) {
      var sql = "select postCCCredit(-15, 'unknown', min(cohead_id)) as result" +
                "  from cohead;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res, "postCCcredit", -3);
        done();
      });
    });

    it("should fail trying to post a non-credit transaction", function (done) {
      var sql = "select postCCCredit(ccpay_id, 'cohead', payco_cohead_id) as result" +
                "  from payco join ccpay on payco_ccpay_id = ccpay_id"  +
                " where ccpay_type != 'R' limit 1;";
      datasource.query(sql, adminCred, function (err, res) {
        if (! err && res.rowCount === 0) {
          console.log("could not find a non-credit transaction to try");
        } else {
          dblib.assertErrorCode(err, res, "postCCcredit", -4);
        }
        done();
      });
    });

    it("needs a charge transaction", function (done) {
      var sql = "insert into ccpay ("                                           +
           "    ccpay_ccard_id, ccpay_cust_id, ccpay_type, ccpay_amount,"     +
           "    ccpay_curr_id, ccpay_auth, ccpay_auth_charge,"                +
           "    ccpay_order_number,"                                          +
           "    ccpay_order_number_seq,"                                      +
           "    ccpay_r_approved, ccpay_r_avs, ccpay_r_code, ccpay_r_error,"  +
           "    ccpay_r_message,  ccpay_r_ordernum,          ccpay_r_ref,"    +
           "    ccpay_card_type,  ccpay_status"                               +
           ") select "                                                        +
           "    ccard_id, ccard_cust_id, 'C', 123.45,"                        +
           "    basecurrid(), false, 'C',"                                    +
           "    cohead_number,"                                               +
           "    (SELECT MAX(COALESCE(ccpay_order_number_seq, -1)) + 1"        +
           "       FROM ccpay WHERE ccpay_order_number = cohead_number),"     +
           "    'Approved',       'YY',    '12345',  'No Error',"             +
           "    cohead_id::text,  cohead_number,  cohead_number,"             +
           "     ccard_type,      'C'"                                        +
           "    from ccard join custinfo on ccard_cust_id = cust_id"          +
           "    join cohead on cust_id = cohead_cust_id"                      +
           "   where cohead_status = 'O'"                                     +
           " limit 1"                                                         +
           " returning ccpay_id, ccpay_r_message as cohead_id,"               +
           "           ccpay_amount, ccpay_curr_id;";
      // misusing ccpay_r_message to hold the cohead_id
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        var row = res.rows[0];
        id.ccpay = { cohead_id: row.cohead_id,    ccpay_id: row.ccpay_id,
                     amount:    row.ccpay_amount, currency: row.ccpay_curr_id
                   };
        done();
      });
    });

    it("needs a posted cash receipt", function (done) {
      var sql  = "select postcccashreceipt($1, $2, 'cohead', $3) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ id.ccpay.ccpay_id,
                                          id.ccpay.cohead_id,
                                          id.ccpay.ccpay_amount ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].result, ">", 0);
        id.ccpay.aropen_id = res.rows[0].result;
        done();
      });
    });

    it("needs a payco record", function (done) {
      var sql  = "insert into payco (payco_ccpay_id, payco_cohead_id,"  +
                 "                   payco_amount, payco_curr_id"       +
                 ") values ($1, $2, $3, $4)"                            +
                 " returning payco_ccpay_id;",
          cred = _.extend({}, adminCred,
                          { parameters: [ id.ccpay.ccpay_id,
                                          id.ccpay.cohead_id,
                                          id.ccpay.amount,
                                          id.ccpay.currency ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("needs that charge credited", function (done) {
      var sql = "insert into ccpay ("                                          +
                "    ccpay_ccard_id, ccpay_cust_id, ccpay_type, ccpay_amount," +
                "    ccpay_curr_id, ccpay_auth, ccpay_auth_charge,"            +
                "    ccpay_order_number,"                                      +
                "    ccpay_order_number_seq,"                                  +
                "    ccpay_card_type,  ccpay_status"                           +
                ") select "                                                    +
                "    ccpay_ccard_id, ccpay_cust_id, 'R', ccpay_amount,"        +
                "    ccpay_curr_id,  ccpay_auth, ccpay_auth_charge,"           +
                "    ccpay_order_number,"                                      +
                "    (SELECT MAX(COALESCE(ccpay_order_number_seq, -1)) + 1"    +
                "       FROM ccpay inr"                                        +
                "      WHERE inr.ccpay_order_number=out.ccpay_order_number),"  +
                "     ccpay_card_type, 'X'"                                    +
                "    from ccpay out where ccpay_id = $1"                       +
                " returning ccpay_id, ccpay_order_number;",
           cred = _.extend({}, adminCred, {parameters: [ id.ccpay.ccpay_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        var row = res.rows[0];
        id.refund = { ccpay_id:  row.ccpay_id,
                      cohead_id: id.ccpay.cohead_id,
                      ordernum:  row.ccpay_order_number };
        done();
      });
    });

    it("should succeed posting a sales order credit", function (done) {
      var sql = "select postCCCredit($1, 'cohead', $2) as result;",
          cred = _.extend({}, adminCred,
                    { parameters: [ id.refund.ccpay_id, id.refund.cohead_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });

    it.skip("should have posted to the prepaid account for cohead");

    it("should have inserted into payco for cohead", function (done) {
      var sql  = "select * from payco where payco_ccpay_id = $1;",
          cred = _.extend({}, adminCred, {parameters: [ id.refund.ccpay_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">=", 1);
        var cr = _.find(res.rows,
                        function (e) { return e.payco_amount === id.refund.amount; }),
            dr = _.find(res.rows,
                        function (e) { return e.payco_amount === 0 - cr; });
        assert.isNotNull(cr, "charge payco");
        assert.isNotNull(dr, "credit payco");
        done();
      });
    });

    it("should have changed the g/l for cohead", function (done) {
      var sql = "select sum(gltrans_amount) as amt,"                    +
                "       gltrans_amount >= 0 as sign"                    +
                "  from gltrans"                                        +
                " where gltrans_docnumber ~* $1"                        +
                "   and gltrans_notes ~ 'Credit via Credit Card'"       +
                " group by sign;",
          cred = _.extend({}, adminCred, { parameters: [id.refund.ordernum] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 2, "debits and credits");
        assert.equal(res.rows[0].amt, -1 * res.rows[1].amt, "gl should balance");
        done();
      });
    });

    it.skip("should fail -1 when the credit card has no default bankaccnt");

    it.skip("should succeed posting an aropen credit");
    it.skip("should create an ardebitmemo for aropen");
    it.skip("should apply and post the aropen to the ardebitmemo");
    it.skip("should change the g/l for aropen");

    it.skip("should succeed posting an cmhead credit");
    it.skip("should create an ardebitmemo for cmhead");
    it.skip("should apply and post the cmhead to the ardebitmemo");
    it.skip("should change the g/l for cmhead");

    it.skip("should post to the customer a/r account for cmhead");
    it.skip("should post to the customer a/r account for aropen");

  });

})();
