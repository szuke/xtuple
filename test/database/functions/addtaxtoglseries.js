var _      = require('underscore'),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  'use strict';

  describe.skip('addTaxToGLSeries() - must CREATE an invoice', function () {
    // TODO: use path.join(__dirname,...) like setmetric and financialreport?
    var adminCred   = dblib.adminCred,
        datasource  = dblib.datasource,
        closeEnough = 0.006,
        exchangeRate,
        exchangeRateId,
        currid,
        glseq,
        taxhistoid,
        parentid,
        taxsum
        ;

    it("should find the oid of the invchead taxhist table", function (done) {
      var sql = "select oid from pg_class where relname = 'invcheadtax';";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        taxhistoid = res.rows[0].oid;
        assert.isNotNull(taxhistoid);
        done();
      });
    });

    it("should get info about an invchead record", function (done) {
      var sql = "select count(*) as num, taxhist_parent_id, taxhist_curr_id," +
                "       currrate(taxhist_curr_id, CURRENT_DATE) as rate"      +
                "  from invcheadtax"                                          +
                " where taxhist_curr_id is not null"                          +
                " group by taxhist_parent_id, taxhist_curr_id"                +
                " order by num desc limit 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        parentid = res.rows[0].taxhist_parent_id;
        currid   = res.rows[0].taxhist_curr_id;
        exchangeRate = res.rows[0].rate;
        assert.isDefined(parentid, 'taxhist_parent_id');
        assert.isDefined(currid,   'taxhist_curr_id');
        assert.isDefined(exchangeRate, 'exchange rate');
        done();
      });
    });

    it("needs an exchange rate", function (done) {
      var sql = "insert into curr_rate ("                                   +
                "  curr_id, curr_rate, curr_effective, curr_expires"        +
                ") select"                                                  +
                "  $1, 2.34, CURRENT_DATE, CURRENT_DATE + interval '1 day'" +
                "  from curr_symbol where curr_id = $1 and not curr_base"   +
                " returning curr_rate_id;",
          admin = _.extend({}, adminCred, { parameters: [ currid ]});
      datasource.query(sql, admin, function (err, res) {
        if (err) {
          assert.match(err.message, /overlaps with another/);
        } else if (res && res.rowCount > 0) {
          exchangeRateId = res.rows[0].curr_rate_id;
        }
        done();
      });
    });
    after(function () {
      var sql   = "delete from curr_rate where curr_rate_id = $1;",
          admin = _.extend({}, adminCred, { parameters: [ exchangeRateId ] });
      if (exchangeRateId) {
        datasource.query(sql, admin);
      }
    });

    it("should get a glseries sequence", function (done) {
      var sql = "select fetchGLSequence() as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        glseq = res.rows[0].result;
        done();
      });
    });

    it("should run without error", function (done) {
      var sql = "select addTaxToGLSeries($1, 'A/R', 'IN',"                     +
                "        invchead_invcnumber, $2, CURRENT_DATE, CURRENT_DATE," +
                "       'invcheadtax', $3, 'addTaxToGLSeries test') as result" +
                "  from invchead where invchead_id = $4;",
          admin = _.extend({}, adminCred,
                           { parameters: [glseq, currid, parentid, parentid] });
      datasource.query(sql, admin, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        taxsum = res.rows[0].result;
        done();
      });
    });

    it("should return the glseries sum", function (done) {
      var sql = "select sum(glseries_amount) as result from glseries" +
                " where glseries_sequence=$1;",
          admin = _.extend({}, adminCred, { parameters: [ glseq ]});
      datasource.query(sql, admin, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.closeTo(res.rows[0].result, taxsum, closeEnough);
        done();
      });
    });

    it("taxhist records should match expectations", function (done) {
      var sql = "select sum(taxhist_tax * taxhist_curr_rate) as taxsum,"   +
                "       bool_and(taxhist_docdate = CURRENT_DATE) as doc,"  +
                "       bool_and(taxhist_distdate= CURRENT_DATE) as dist," +
                "       bool_and(taxhist_curr_id = $1) as curr,"           +
                "       avg(taxhist_curr_rate) as rate"                    +
                "  from taxhist"                                           +
                " where taxhist_parent_id = $2"                            +
                "   and tableoid = $3;",
          admin = _.extend({}, adminCred,
                           { parameters: [ currid, parentid, taxhistoid ]});
      datasource.query(sql, admin, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.closeTo(res.rows[0].taxsum, taxsum, closeEnough);
        assert.isTrue(res.rows[0].doc);
        assert.isTrue(res.rows[0].dist);
        assert.isTrue(res.rows[0].curr);
        assert.closeTo(res.rows[0].rate, exchangeRate, 0.001);
        done();
      });
    });
  });
}());
