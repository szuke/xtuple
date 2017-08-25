var _      = require('underscore'),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  'use strict';

  describe('currToBase()', function () {
    var adminCred   = dblib.adminCred,
        datasource  = dblib.datasource,
        closeEnough = 0.006,
        basecurr, altcurr;

    it("needs base and alternate currency info", function (done) {
      var sql = "select s.curr_id AS id, curr_base AS isbase,"              +
                "       min(curr_effective) AS mindate,"                    +
                "       max(curr_expires) AS maxdate,"                      +
                "       (select curr_rate from curr_rate"                   +
                "         where curr_id = s.curr_id"                        +
                "           and current_date between curr_effective and"    +
                "                                    curr_expires) AS rate" +
                "  from curr_symbol s"                                      +
                "  join curr_rate   r ON s.curr_id = r.curr_id"             +
                " group by s.curr_id"                                       +
                " order by curr_base desc"                                  +
                " limit 2;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 2);
        assert.isTrue(res.rows[0].isbase);
        basecurr = res.rows[0];
        altcurr  = res.rows[1];
        done();
      });
    });

    it("needs alternate currency exchange rate", function (done) {
      var sql = "insert into curr_rate ("                                +
                "  curr_id, curr_rate, curr_effective, curr_expires"     +
                ") values ("                                             +
                "  $1, 1.5, current_date, current_date + interval '1 day'" +
                ") returning curr_rate;",
          cred = _.extend({}, adminCred, { parameters: [ altcurr.id ] });
      if (altcurr.rate) {
        done();
      } else {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          if (res.rowCount >= 1) {
            altcurr.rate = res.rows[0].curr_rate;
          }
          done();
        });
      }
    });

    it("should fail if bad currency", function (done) {
      var sql = "select currToBase(-1, 1, current_date) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res, 'currToBase', -1);
        done();
      });
    });

    it("should fail if bad date", function (done) {
      var sql = "select currToBase($1, 1.0, '1900-01-01') as result;",
          cred = _.extend({}, adminCred, { parameters: [ altcurr.id ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, 'currToBase', -1);
        done();
      });
    });

    it("should succeed for base currency", function (done) {
      var sql = "select currToBase($1, 1.0, CURRENT_DATE) as result;",
          cred = _.extend({}, adminCred, { parameters: [ basecurr.id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.closeTo(res.rows[0].result, 1.0, closeEnough);
        done();
      });
    });

    it("should succeed with null value", function (done) {
      var sql = "select currToBase(-1, NULL, '1900-01-01') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.closeTo(res.rows[0].result, 0, closeEnough);
        done();
      });
    });

    it("should succeed with 0.0", function (done) {
      var sql = "select currToBase(-1, 0.0, '1900-01-01') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.closeTo(res.rows[0].result, 0, closeEnough);
        done();
      });
    });

    it("should succeed for non-base currency", function (done) {
      var sql = "select currToBase($1, 1.0, CURRENT_DATE) as result;",
          cred = _.extend({}, adminCred, { parameters: [ altcurr.id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.closeTo(res.rows[0].result, 1.0 / altcurr.rate, closeEnough);
        done();
      });
    });

    it("should succeed for good date", function (done) {
      var sql = "select currToBase($1, 1.0, $2) as result;",
          cred = _.extend({}, adminCred, { parameters: [ altcurr.id, altcurr.mindate ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.notEqual(res.rows[0].result, 1.0);
        done();
      });
    });

    it("should succeed for null date", function (done) {
      var sql = "select currToBase($1, 1.0, NULL) as result;",
          cred = _.extend({}, adminCred, { parameters: [ altcurr.id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.closeTo(res.rows[0].result, 1.0 / altcurr.rate, closeEnough);
        done();
      });
    });

  });
}());
