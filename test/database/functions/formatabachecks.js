var _      = require("underscore"),
    assert = require("chai").assert,
    dblib  = require("../dblib");

(function () {
  "use strict";

  describe("formatABAchecks()", function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        aud,
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

    it("needs AUD", function (done) {
      var sql = "select curr_id from curr_symbol where curr_abbr = 'AUD';";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        if (res.rowCount === 1) {
          aud = res.rows[0].curr_id;
console.log("exists", aud);
          done();
        } else {
          sql = "insert into curr_symbol (curr_name, curr_symbol, curr_abbr)" +
                " values('Australian Dollar', '$AU', 'AUD') returning curr_id;";
          datasource.query(sql, adminCred, function (err, res) {
            assert.isNull(err);
            assert.equal(res.rowCount, 1);
            aud = res.rows[0].curr_id;
console.log("created", aud);
            done();
          });
        }
      });
    });

    it("needs an exchange rate", function (done) {
      var sql = "select curr_rate_id from curr_rate"    +
                " where curr_id = $1"                   +
                "   and current_date between curr_effective and curr_expires;",
          cred = _.extend({}, adminCred, { parameters: [ aud ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        if (res.rowCount === 0) {
          sql = "insert into curr_rate ("                               +
                " curr_id, curr_rate, curr_effective, curr_expires"     +
                ") values ("                                            +
                " $1, 1 + random(), now(), now() + interval '1 week'"   +
                ") returning curr_rate_id;";
          datasource.query(sql, cred, function (err, res) {
            assert.isNull(err);
            assert.equal(res.rowCount, 1);
            done();
          });
        } else {
          done();
        }
      });
    });

    it("needs an ACH-enabled bank account in AUD", function (done) {
      var sql = "select * from bankaccnt where bankaccnt_curr_id = $1"  +
                 " order by bankaccnt_ach_enabled desc limit 1;",
          cred = _.extend({}, adminCred, { parameters: [ aud ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        if (res.rowCount === 1) {
          bankaccnt = res.rows[0];
          bankRE = { routing:     new RegExp(bankaccnt.bankaccnt_routing),
                     bankname:    new RegExp(bankaccnt.bankaccnt_bankname
                                                      .substring(0, 3)),
                     accntnumber: new RegExp(bankaccnt.bankaccnt_accntnumber)
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
                "  bankaccnt_ach_enabled, bankaccnt_ach_genchecknum"            +
                ") select"                                                      +
                "  'Aussie Bank', 'test formatABAchecks', 'AussieBank',"        +
                "  '123456000',   true,                   true,"                +
                "  10000,         'K',                    bankaccnt_accnt_id,"  +
                "  bankaccnt_check_form_id, bankaccnt_userec,"                  +
                "  bankaccnt_rec_accnt_id,  $1,"                                +
                "  '123456000',"                                                +
                "  true, true"                                                  +
                " from bankaccnt where bankaccnt_name = 'EBANK' returning *;";
          datasource.query(sql, cred, function (err, res) {
            assert.isNull(err);
            assert.equal(res.rowCount, 1);
            bankaccnt = res.rows[0];
            bankRE = { routing:     new RegExp(bankaccnt.bankaccnt_routing),
                       bankname:    new RegExp(bankaccnt.bankaccnt_bankname
                                                        .substring(0, 3)),
                       accntnumber: new RegExp(bankaccnt.bankaccnt_accntnumber)
                     };
            assert.operator(bankaccnt.bankaccnt_id, ">", 0);
            done();
          });
        }
      });
    });

    it("needs a vendor with an Australian bank accnt", function (done) {
      var sql  = "update vendinfo set"                                          +
                 "  vend_ach_use_vendinfo = true,"                              +
                 "  vend_ach_enabled      = true,"                              +
                 "  vend_ach_routingnumber = encrypt('123456000', $1, 'bf'),"   +
                 "  vend_ach_accntnumber = encrypt('12345678',  $1, 'bf')"      +
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
                                                         aud ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 1);
        checkhead = res.rows;
        console.log("created", checkhead.length);
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
      var sql  = "select * from formatABAchecks($1, $2, $3)",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "formatABAchecks", -1);
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
      var sql  = "select * from formatABAchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "" ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "formatABAchecks", -2);
        done();
      });
    });

    it("should fail when there's no corresponding bank", function (done) {
      var sql  = "select * from formatABAchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            -2,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "formatABAchecks", -3);
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
      var sql  = "select * from formatABAchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ]
          });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "formatABAchecks", -4);
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
      var sql  = "select * from formatABAchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "formatABAchecks", -5);
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
      var sql  = "select * from formatABAchecks($1, $2, $3);",
          cred = _.extend({}, adminCred, { parameters: [
                                            bankaccnt.bankaccnt_id,
                                            checkhead[0].checkhead_id,
                                            "encryption key" ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "formatABAchecks", -6);
        done();
      });
    });

    it("needs bankaccnt with ACH enabled & good routing number", function (done) {
      var sql  = "update bankaccnt set bankaccnt_routing = $1"  +
                 " where bankaccnt_id = $2 returning bankaccnt_id;",
          cred = _.extend({}, adminCred,
                          { parameters: [ '123456000',
                                          bankaccnt.bankaccnt_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].bankaccnt_id, bankaccnt.bankaccnt_id);
        done();
      });
    });

    it("should return one check, header, and footer", function (done) {
      var sql  = "select * from formatABAchecks($1, $2, $3);",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id,
                                          checkhead[0].checkhead_id,
                                          enckey ] }),
          amountRE = new RegExp(checkhead[0].checkhead_amount);

      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 4);
        assert.match(res.rows[0].achline_value, bankRE.bankname, '/bank name/');

        assert.match(res.rows[1].achline_value, amountRE);
        assert.match(res.rows[1].achline_value, bankRE.routing, '/routing/');

        assert.match(res.rows[2].achline_value, amountRE);
        assert.match(res.rows[2].achline_value, bankRE.accntnumber, '/account/');

        assert.match(res.rows[3].achline_value, amountRE); // TODO: match twice
        done();
      });
    });

    it("should return the other checks, header, and footer", function (done) {
      var sql  = "select * from formatABAchecks($1, NULL, $2);",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id, enckey ] });
      datasource.query(sql, cred, function (err, res) {
        var i;

        assert.isNull(err);
        assert.equal(res.rowCount, checkhead.length - 1 + 3,
                        "number of outstanding checks + header + footer");
        assert.match(res.rows[0].achline_value, bankRE.bankname, '/bank name/');

        for (i = 1; i < res.rowCount - 3; i++) {
          assert.match(res.rows[i].achline_value, bankRE.routing, '/routing/');
          assert.match(res.rows[i].achline_value,
                       new RegExp(checkhead[i].checkhead_amount), '/amount/');
        }

        assert.match(res.rows[res.rowCount - 2].achline_value, bankRE.routing, 'footer');
        assert.match(res.rows[res.rowCount - 1].achline_value, /^7999-999   /, 'footer');
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
