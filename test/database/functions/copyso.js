var _    = require("underscore"),
  assert = require('chai').assert,
  dblib  = require('../dblib');

(function () {
  "use strict";

  describe('copySO()', function () {

    var datasource = dblib.datasource,
        adminCred = dblib.generateCreds(),
        diffcust = {},
        samecust = {},
        oldso
        ;

    it("should find an order to copy", function (done) {
      var sql = "select *,"                                             +
                 "      (select count(*) from coitem"                   +
                 "        where coitem_cohead_id = cohead_id) as lines" +
                "  from cohead limit 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        oldso = res.rows[0];
        done();
      });
    });

    it("should copy with the same customer", function (done) {
      var sql = "select copySO($1, $2, current_date) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ oldso.cohead_id, oldso.cohead_cust_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        samecust.cohead_id = res.rows[0].result;
        assert.operator(samecust.cohead_id, '>=', 0);
        done();
      });
    });

    it("should have similar data", function (done) {
      var sql  = "select cohead.*,"                                     +
                 "       (select count(*) from coitem"                  +
                 "         where coitem_cohead_id = $1) as lines"       +
                 "  from cohead where cohead_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ samecust.cohead_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, 'one row');
        samecust = res.rows[0];
        assert.notEqual(samecust.cohead_id, 0, 'id');
        assert.notEqual(samecust.cohead_id, oldso.cohead_id, 'id');
        assert.notEqual(samecust.cohead_number, oldso.cohead_number, 'number');
        assert.equal(samecust.cohead_cust_id, oldso.cohead_cust_id, 'cust_id');
        assert.equal(samecust.cohead_shiptoname, oldso.cohead_shiptoname, 'shiptoname');
        assert.equal(samecust.cohead_shipvia, oldso.cohead_shipvia, 'shipvia');
        assert.equal(samecust.cohead_freight, oldso.cohead_freight, 'freight');
        assert.equal(samecust.cohead_misc, oldso.cohead_misc, 'misc');
        assert.equal(samecust.cohead_holdtype, oldso.cohead_holdtype, 'holdtype');
        assert.equal(samecust.cohead_ordercomments, oldso.cohead_ordercomments, 'ordercomments');
        assert.equal(samecust.lines, oldso.lines, 'line count');
        done();
      });
    });

    it("should copy with a different customer", function (done) {
      var sql = "select copySO($1, cust_id, current_date) as result"    +
                "  from custinfo"                                       +
                " where cust_id != $2 and cust_active limit 1;",
          cred = _.extend({}, adminCred,
                          { parameters: [ oldso.cohead_id, oldso.cohead_cust_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        diffcust.cohead_id = res.rows[0].result;
        assert.operator(diffcust.cohead_id, '>=', 0);
        done();
      });
    });

    it("should have similar data", function (done) {
      var sql  = "select cohead.*,"                                      +
                 "       (select count(*) from coitem"                   +
                 "         where coitem_cohead_id = cohead_id) as lines" +
                 "  from cohead where cohead_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ diffcust.cohead_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, 'row count for ' + diffcust.cohead_id);
        diffcust = res.rows[0];
        assert.notEqual(diffcust.cohead_id, 0, 'id');
        assert.notEqual(diffcust.cohead_id, oldso.cohead_id, 'id');
        assert.notEqual(diffcust.cohead_number, oldso.cohead_number, 'number');
        assert.notEqual(diffcust.cohead_cust_id, oldso.cohead_cust_id, 'cust_id');
        if (oldso.cohead_shiptoname) {
          assert.notEqual(diffcust.cohead_shiptoname, oldso.cohead_shiptoname, 'shiptoname');
        }
        assert.equal(diffcust.cohead_freight, oldso.cohead_freight, 'freight');
        assert.equal(diffcust.cohead_misc, oldso.cohead_misc, 'misc');
        assert.equal(diffcust.cohead_holdtype, oldso.cohead_holdtype, 'holdtype');
        assert.equal(diffcust.cohead_ordercomments, oldso.cohead_ordercomments, 'ordercomments');
        assert.equal(diffcust.lines, oldso.lines, 'line count');
        done();
      });
    });

    it("should fail with a non-existent so", function (done) {
      var sql = "select copySO(-5, $1, current_date) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ oldso.cohead_cust_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /copyso.*-[1-9]/g);
        done();
      });
    });

    it("should fail with a non-existent customer", function (done) {
      var sql = "select copySO($1, -5, current_date) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ oldso.cohead_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /copyso.*-[1-9]/g);
        done();
      });
    });

  });

}());
