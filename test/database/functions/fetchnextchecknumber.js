var _      = require('underscore'),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  'use strict';

  describe('fetchNextCheckNumber()', function () {
    var adminCred   = dblib.adminCred,
        datasource  = dblib.datasource,
        bankaccnt   = {},
        checkhead   = {}
        ;

    it('needs a checking account to work with', function (done) {
      var sql = "INSERT INTO bankaccnt ("                                      +
                "  bankaccnt_name, bankaccnt_nextchknum"                       +
                ") VALUES ("                                                   +
                "  'nextCheckNumber' || (random() * 10 - 1)::INTEGER, 10000"   +
                ") RETURNING *;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        bankaccnt = res.rows[0];
        done();
      });
    });

    it("should return the assigned next number", function (done) {
      var sql = "SELECT fetchNextCheckNumber($1) AS result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, bankaccnt.bankaccnt_nextchknum);
        bankaccnt.bankaccnt_nextchknum = res.rows[0].result + 1;
        done();
      });
    });

    it("should return the assigned next number again", function (done) {
      var sql = "SELECT fetchNextCheckNumber($1) AS result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, bankaccnt.bankaccnt_nextchknum);
        bankaccnt.bankaccnt_nextchknum = res.rows[0].result + 1;
        done();
      });
    });

    it("needs a gap in check numbers", function (done) {
      var sql = "INSERT INTO checkhead ("                                      +
                "  checkhead_recip_type, checkhead_recip_id, checkhead_for,"   +
                "  checkhead_bankaccnt_id, checkhead_amount, checkhead_notes," +
                "  checkhead_checkdate, checkhead_curr_rate, checkhead_number" +
                ") SELECT 'V', vend_id, 'test',"                               +
                "         $1, random() * 100, 'fetchNextCheckNum',"            +
                "         CURRENT_DATE, 1, $2 + 5"                             +
                "    FROM vendinfo WHERE vend_active LIMIT 1"                  +
                " RETURNING *;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id,
                                          bankaccnt.bankaccnt_nextchknum ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        checkhead = res.rows[0];
        done();
      });
    });

    it("should fill the gap", function (done) {
      var sql = "SELECT fetchNextCheckNumber($1) AS result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankaccnt.bankaccnt_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, bankaccnt.bankaccnt_nextchknum);
        bankaccnt.bankaccnt_nextchknum = res.rows[0].result + 1;
        done();
      });
    });

  });
}());
