var _      = require("underscore"),
    assert = require("chai").assert,
    dblib  = require("../dblib");

(function () {
  "use strict";

  describe("voidPostedCheck()", function () {

    var datasource = dblib.datasource,
        adminCred = dblib.generateCreds(),
        bankaccnt,
        bankrec,
        checkCred,
        checkhead = {},
        gltrans,
        journal ;

    it("looks for a bank account to work with", function (done) {
      var sql = "SELECT * FROM bankaccnt WHERE bankaccnt_id IN ("       +
                "   SELECT bankrec_bankaccnt_id FROM bankrec"           +
                "   GROUP BY bankrec_bankaccnt_id"                      +
                "   HAVING BOOL_AND(bankrec_posted)) LIMIT 1;"
                ;
      datasource.query(sql, adminCred, function (err, res) {
        if (res.rowCount === 1) {
          bankaccnt = res.rows[0];
          assert.isNotNull(bankaccnt, "we found a bank account");
          bankrec = "create";
          done();
        } else {
          var sql = "SELECT * FROM bankaccnt WHERE bankaccnt_id IN ("       +
                    "   SELECT bankrec_bankaccnt_id FROM bankrec"           +
                    "    WHERE bankrec_opendate IN"                         +
                    "      (SELECT MAX(bankrec_opendate) FROM bankrec"      +
                    "        WHERE NOT bankrec_posted)"                     +
                    ") LIMIT 1;"
                    ;
          datasource.query(sql, adminCred, function (err, res) {
            assert.equal(res.rowCount, 1);
            bankaccnt = res.rows[0];
            assert.isNotNull(bankaccnt, "we found a bank account");
            bankrec = "select";
            done();
          });
        }
      });
    });

    it("should get a journal number to use", function (done) {
      var sql = "select fetchJournalNumber('voidPostedCheckTest') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        journal = res.rows[0].result;
        assert.isNotNull(journal);
        checkCred = _.extend({}, adminCred, { parameters: [ journal ] });
        done();
      });
    });

    it('updates the bank account to allow unprinted apchecks to be posted', function(done) {
      var sql = "UPDATE bankaccnt SET bankaccnt_prnt_check=FALSE " +
                " WHERE bankaccnt_id = $1" +
                " RETURNING bankaccnt_id AS result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.equal(res.rowCount, 1);
        assert(res.rows[0].result == bankaccnt.bankaccnt_id, 'bank account was updated');
        done();
      });
    });

    it("should create a check to use", function (done) {
      var sql = "select createCheck($1, 'V',"                     +
                "  (select min(vend_id) from vendinfo),"          +
                "  current_date, 123.45, basecurrid(), NULL, $2," +
                "  'Bearer', 'voidPostedCheck test', true, null) as result",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id, journal ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        checkhead.checkhead_id = res.rows[0].result;
        assert.operator(checkhead.checkhead_id, ">", 0);
        sql = "update checkhead set"                                             +
              "   checkhead_number=fetchNextCheckNumber(checkhead_bankaccnt_id)" +
              " where checkhead_id = $1 and checkhead_journalnumber = $2"        +
              " returning *;";
        checkCred = _.extend({}, adminCred,
                             { parameters: [ checkhead.checkhead_id, journal ] });
        datasource.query(sql, checkCred, function (err, res) {
          assert.equal(res.rowCount, 1);
          checkhead = res.rows[0];
          done();
        });
      });
    });

    it("should fail with a non-existent check", function (done) {
      var sql = "select voidPostedCheck(0 - $1, $2, CURRENT_DATE) as result;";
      datasource.query(sql, checkCred, function (err, res) {
        dblib.assertErrorCode(err, res, "voidPostedCheck");
        done();
      });
    });

    it("should fail with an unposted check", function (done) {
      var sql = "select voidPostedCheck($1, $2, CURRENT_DATE) as result;";
      datasource.query(sql, checkCred, function (err, res) {
        dblib.assertErrorCode(err, res, "voidPostedCheck", -10);
        done();
      });
    });

    it("should post the check", function (done) {
      var sql = "select postCheck($1, $2) as result;";
      datasource.query(sql, checkCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, journal);
        done();
      });
    });

    it("should have affected the gl if posted", function (done) {
      var sql = "select * from gltrans" +
                " where gltrans_misc_id = $1 and gltrans_journalnumber = $2;";
      datasource.query(sql, checkCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">=", 1);
        assert.equal(_.filter(res.rows, function (e) {
                       return e.gltrans_doctype === 'CK';
                     }).length, res.rowCount);
        gltrans = res.rows;
        assert.equal(_.reduce(gltrans,
                              function (sum, e) { return sum + e.gltrans_amount; }, 0),
                     0);
        done();
      });
    });

    it("should return the journal number if successful", function (done) {
      var sql = "select voidPostedCheck($1, $2, CURRENT_DATE) as result;";
      datasource.query(sql, checkCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, journal);
        done();
      });
    });

    it("should have modified the checkhead record", function (done) {
      var sql = "select * from checkhead"       +
                " where checkhead_id = $1 and checkhead_journalnumber = $2;";
      datasource.query(sql, checkCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].checkhead_void);
        assert.isFalse(res.rows[0].checkhead_posted);
        done();
      });
    });

    it("should have affected the gl if voided", function (done) {
      var sql = "select * from gltrans" +
                " where gltrans_misc_id = $1 and gltrans_journalnumber = $2;";
      datasource.query(sql, checkCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">=", 1);
        assert.operator(res.rowCount, ">=", gltrans.length);
        assert.equal(_.filter(res.rows, function (e) {
                       return e.gltrans_doctype === 'CK';
                     }).length, res.rowCount);
        gltrans = res.rows;
        assert.equal(_.reduce(gltrans,
                              function (sum, e) { return sum + e.gltrans_amount; }, 0),
                     0);
        done();
      });
    });

    it("should create a second check to use", function (done) {
      var sql = "select createCheck($1, 'V',"                     +
                "  (select min(vend_id) from vendinfo),"          +
                "  current_date, 123.45, basecurrid(), NULL, $2," +
                "  'Bearer', 'voidPostedCheck test', true, null) as result",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id, journal ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        checkhead.checkhead_id = res.rows[0].result;
        assert.operator(checkhead.checkhead_id, ">", 0);
        sql = "update checkhead set"                                             +
              "   checkhead_number=fetchNextCheckNumber(checkhead_bankaccnt_id)" +
              " where checkhead_id = $1 and checkhead_journalnumber = $2"        +
              " returning *;";
        checkCred = _.extend({}, adminCred,
                             { parameters: [ checkhead.checkhead_id, journal ] });
        datasource.query(sql, checkCred, function (err, res) {
          assert.equal(res.rowCount, 1);
          checkhead = res.rows[0];
          done();
        });
      });
    });

    it("should post the second check", function (done) {
      var sql = "select postCheck($1, $2) as result;";
      datasource.query(sql, checkCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, journal);
        done();
      });
    });

    it("should get an open bankrec to reconcile against", function (done) {
      var sql, cred;
      if (bankrec === "create") {
        sql = "INSERT INTO bankrec (bankrec_bankaccnt_id,"    +
              "  bankrec_opendate, bankrec_openbal"           +
              ") SELECT bankrec_bankaccnt_id,"                +
              "         bankrec_enddate + 1, bankrec_endbal"  +
              "    FROM bankrec"                              +
              "   WHERE bankrec_bankaccnt_id = $1"            +
              "     AND bankrec_posted"                       +
              "   ORDER BY bankrec_enddate DESC"              +
              "   LIMIT 1 RETURNING *;"
              ;
      } else if (bankrec === "select") {
        sql = "SELECT * FROM bankrec"                         +
              " WHERE bankrec_bankaccnt_id = $1"              +
              "   AND bankrec_opendate IN"                    +
              "  (SELECT MAX(bankrec_opendate) FROM bankrec"  +
              "    WHERE NOT bankrec_posted"                  +
              "      AND bankrec_bankaccnt_id = $1"           +
              "  );"
              ;
      }
      cred = _.extend({}, adminCred, { parameters: [ bankaccnt.bankaccnt_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.equal(res.rowCount, 1);
        bankrec = res.rows[0];
        assert.isNotNull(bankrec,              "we have a bank rec");
        assert.isFalse(bankrec.bankrec_posted, "we have an open bank rec");
        done();
      });
    });

    it("should mark the second check as cleared", function (done) {
      var sql = "SELECT toggleBankRecCleared($1, 'GL', gltrans_id,"      +
                "       checkhead_curr_rate, gltrans_amount) AS result"  +
                "  FROM checkhead JOIN gltrans ON (gltrans_doctype='CK'" +
                "                    AND gltrans_misc_id=checkhead_id)"  +
                " WHERE checkhead_id = $2 AND gltrans_amount > 0;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankrec.bankrec_id, checkhead.checkhead_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("should post the bank reconciliation", function (done) {
      var sql = "SELECT postBankReconciliation($1) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ bankrec.bankrec_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, bankrec.bankrec_id);
        done();
      });
    });

    it("should fail if the check has been reconciled", function (done) {
      var sql = "select voidPostedCheck($1, $2, CURRENT_DATE) as result;";
      datasource.query(sql, checkCred, function (err, res) {
        dblib.assertErrorCode(err, res, "voidPostedCheck", -14);
        done();
      });
    });

    it.skip("should fail if there was no check recipient", function (done) {
      var sql = "select voidPostedCheck($1, $2, CURRENT_DATE) as result;";
      datasource.query(sql, checkCred, function (err, res) {
        dblib.assertErrorCode(err, res, "voidPostedCheck", -11);
        done();
      });
    });

  });

})();
