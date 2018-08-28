var _      = require("underscore"),
    assert = require("chai").assert,
    dblib  = require("../dblib");

(function () {
  "use strict";

  describe("formatACHchecks()", function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        bankaccnt,
        bankRE,
        checkhead,
        enckey = 'test key',
        metric = {},
        vendinfo
        ;

    it("needs test to save ACHEnabled", function (done) {
      var sql = "select fetchMetricBool('ACHEnabled') AS ACHEnabled;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        _.each(res.rows[0], function (e, i) { metric[i] = e; });
        done();
      });
    });

    it("needs an ACH-enabled bank account in USD", function (done) {
      var sql  = "select * from bankaccnt"                              +
                 "  join curr_symbol on bankaccnt_curr_id = curr_id"    +
                 " where curr_abbr = 'USD'"                             +
                 " order by bankaccnt_ach_enabled desc limit 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        if (res.rowCount === 1) {
          bankaccnt = res.rows[0];
          bankRE = {
            routing:     new RegExp(bankaccnt.bankaccnt_routing.substring(0, 8)),
            bankname:    new RegExp(bankaccnt.bankaccnt_bankname.substring(0, 23)),
            accntnumber: new RegExp(bankaccnt.bankaccnt_accntnumber.substring(0,17))
          };
          assert.operator(bankaccnt.bankaccnt_id, ">", 0);
          done();
        } else {
          sql = "insert into bankaccnt ("                                       +
                "  bankaccnt_name, bankaccnt_descrip, bankaccnt_bankname,"      +
                "  bankaccnt_accntnumber, bankaccnt_ar, bankaccnt_ap,"          +
                "  bankaccnt_nextchknum, bankaccnt_type, bankaccnt_accnt_id,"   +
                "  bankaccnt_check_form_id, bankaccnt_userec,"                  +
                "  bankaccnt_rec_accnt_id, bankaccnt_curr_id,"                  +
                "  bankaccnt_routing,"                                          +
                "  bankaccnt_ach_enabled, bankaccnt_ach_genchecknum,"           +
                "  bankaccnt_ach_desttype, bankaccnt_ach_origintype,"           +
                "  bankaccnt_ach_dest,     bankaccnt_ach_origin"                +
                ") select"                                                      +
                "  'US Bank',     'test formatACHchecks', 'USBank',"            +
                "  '123456000',   true,                   true,"                +
                "  10000,         'K',                    bankaccnt_accnt_id,"  +
                "  bankaccnt_check_form_id, bankaccnt_userec,"                  +
                "  bankaccnt_rec_accnt_id,  $1,"                                +
                "  '123456000',"                                                +
                "  true, true,"                                                 +
                "  'B', 'B',"                                                   +
                "  '123456000', '000654321'"                                    +
                " from bankaccnt where bankaccnt_name = 'EBANK' returning *;";
          datasource.query(sql, adminCred, function (err, res) {
            assert.isNull(err);
            assert.equal(res.rowCount, 1);
            bankaccnt = res.rows[0];
            bankRE = {
              routing:     new RegExp(bankaccnt.bankaccnt_routing.substring(0, 8)),
              bankname:    new RegExp(bankaccnt.bankaccnt_bankname.substring(0, 23)),
              accntnumber: new RegExp(bankaccnt.bankaccnt_accntnumber.substring(0,17))
            };
            assert.operator(bankaccnt.bankaccnt_id, ">", 0);
            done();
          });
        }
      });
    });

    it("needs a vendor with a US bank accnt", function (done) {
      var sql  = "update vendinfo set"                                          +
                 "  vend_ach_use_vendinfo = true,"                              +
                 "  vend_ach_enabled      = true,"                              +
                 "  vend_ach_routingnumber = encrypt('123456000', $1, 'bf'),"   +
                 "  vend_ach_accntnumber   = encrypt('123456789', $1, 'bf')"    +
                 " where vend_number = 'UPS' returning vendinfo.*;",
          cred = _.extend({}, adminCred, { parameters: [ enckey ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        vendinfo = res.rows[0];
        done();
      });
    });

    it("needs several checks", function (done) {
      var sql = "select createCheck($1, 'V', $2, current_date,"            +
                "                   (round(random() * 10000)/2)::numeric," +
                "                   $3, NULL, NULL, 'test', 'test', true)" +
                "       as checkhead_id"                                   +
                "  from generate_series(1,5);",
          cred = _.extend({}, adminCred, { parameters: [ bankaccnt.bankaccnt_id,
                                                         vendinfo.vend_id,
                                                         bankaccnt.bankaccnt_curr_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 1);
        checkhead = res.rows;
        done();
      });
    });

    it("needs ! ACHEnabled to check failure", function (done) {
      var sql = "select setMetric('ACHEnabled', 'f') AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should fail when ACH is not enabled", function (done) {
      var sql  = "select * from formatACHchecks($1, $2, $3)",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err); //dblib.assertErrorCode(err, res, "formatACHchecks", -1);
        done();
      });
    });

    it("needs test to reset ACHEnabled", function (done) {
      var sql = "select setMetric('ACHEnabled', 't') AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should fail when there's no encryption key", function (done) {
      var sql  = "select * from formatACHchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "" ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err); //dblib.assertErrorCode(err, res, "formatACHchecks", -2);
        done();
      });
    });

    it("should fail when there's no corresponding bank", function (done) {
      var sql  = "select * from formatACHchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            -2,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err); //dblib.assertErrorCode(err, res, "formatACHchecks", -3);
        done();
      });
    });

    it("needs ACH disabled on the bankaccnt for testing errs", function (done) {
      var sql  = "update bankaccnt set bankaccnt_ach_enabled = false"  +
                 " where bankaccnt_id = $1 returning bankaccnt_id;",
          cred = _.extend({}, adminCred, { parameters: [ bankaccnt.bankaccnt_id ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].bankaccnt_id, bankaccnt.bankaccnt_id);
          done();
        });
    });

    it("should fail when the bankaccnt has ACH disabled", function (done) {
      var sql  = "select * from formatACHchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ]
          });
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err); //dblib.assertErrorCode(err, res, "formatACHchecks", -4);
        done();
      });
    });

    it("needs bankaccnt with ACH enabled & no routing number to test errs",
       function (done) {
      var sql  = "update bankaccnt set bankaccnt_ach_enabled = true,"  +
                 "                     bankaccnt_routing     = ''"     +
                 " where bankaccnt_id = $1 returning bankaccnt_id;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].bankaccnt_id, bankaccnt.bankaccnt_id);
        done();
      });
    });

    it("should fail when the bankaccnt has no routing number", function (done) {
      var sql  = "select * from formatACHchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err); //dblib.assertErrorCode(err, res, "formatACHchecks", -5);
        done();
      });
    });

    it("needs bankaccnt with ACH enabled & bad routing number to test errs",
       function (done) {
      var sql  = "update bankaccnt set bankaccnt_routing = 'ABC'"  +
                 " where bankaccnt_id = $1 returning bankaccnt_id;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].bankaccnt_id, bankaccnt.bankaccnt_id);
        done();
      });
    });

    it("should fail when the bankaccnt has bad routing number", function (done) {
      var sql  = "select * from formatACHchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err); //dblib.assertErrorCode(err, res, "formatACHchecks", -6);
        done();
      });
    });

    it("needs bankaccnt with ACH enabled & good routing number", function (done) {
      var sql  = "update bankaccnt set bankaccnt_routing = $1"  +
                 " where bankaccnt_id = $2 returning bankaccnt_id;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_routing,
                                          bankaccnt.bankaccnt_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].bankaccnt_id, bankaccnt.bankaccnt_id);
        done();
      });
    });

    it("should return one check, header, and footer", function (done) {
      var sql  = "select * from formatACHchecks($1, $2, $3);",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id,
                                          checkhead[0].checkhead_id,
                                          enckey ] }),
          amountRE = new RegExp(checkhead[0].checkhead_amount);

      datasource.query(sql, cred, function (err, res) {
        var offset = 0;
        assert.isNull(err);
        assert.equal(res.rowCount, 10, 'one block');
        assert.match(res.rows[0].achline_value, /101.*094101/, '/bank/');

        if (res.rows[1].achline_value.match(/^8/)) {
          offset = 1;
          assert.match(res.rows[1].achline_value, bankRE.routing, '/bank/');
        }

        assert.match(res.rows[2 - offset].achline_value, amountRE,           'debit');
        assert.match(res.rows[2 - offset].achline_value, bankRE.accntnumber, '/acct/');

        assert.match(res.rows[3 - offset].achline_value, amountRE,    'credit');
        assert.match(res.rows[3 - offset].achline_value, /123456000/, '/vend bank/');
        assert.match(res.rows[3 - offset].achline_value, /123456789/, '/vend acct/');

        assert.match(res.rows[4 - offset].achline_value, bankRE.routing, '/bank/');

        done();
      });
    });

    it("should return the other checks, header, and footer", function (done) {
      var sql  = "select * from formatACHchecks($1, NULL, $2);",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id, enckey ] });
      datasource.query(sql, cred, function (err, res) {
        var i = 0, amountRE;

        assert.isNull(err);
        assert.equal(res.rowCount % 10, 0, '10-line blocks');
        assert.operator(res.rowCount, '>=', 2 * checkhead.length + 2 + 1);
        assert.operator(res.rowCount, '<=', 2 * checkhead.length + 2 + 1 + 10);

        assert.match(res.rows[i++].achline_value, bankRE.routing, '/bank/');
        assert.match(res.rows[i++].achline_value, bankRE.routing, '/bank/');
        for (i = 2; i < 2 * checkhead.length; i += 2) {
          amountRE = new RegExp(checkhead[0].checkhead_amount);
          assert.match(res.rows[i].achline_value, amountRE,           'debit');
          assert.match(res.rows[i].achline_value, bankRE.accntnumber, '/acct/');

          assert.match(res.rows[i + 1].achline_value, amountRE,    'credit');
          assert.match(res.rows[i + 1].achline_value, /123456000/, '/vend bank/');
          assert.match(res.rows[i + 1].achline_value, /123456789/, '/vend acct/');
        }

        assert.match(res.rows[i++].achline_value, bankRE.routing, '/routing/');
        for ( ; i < res.rowCount; i++) {
          assert.match(res.rows[i].achline_value, /^9.*[ 9]*$/);
        }
        done();
      });
    });

    it("needs test to restore ACHEnabled", function (done) {
      if (metric.ACHEnabled === false) {
        var sql = "select setMetric('ACHEnabled', 'f') AS result;";
        datasource.query(sql, adminCred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          done();
        });
      }
      done();
    });

  });

})();
