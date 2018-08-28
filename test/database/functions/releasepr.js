var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";


  describe('releasePR()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        poitem     = {},
        pr
        ;

    it.skip("should build a new pr instead of looking for an existing one");
    it("needs a purchase request", function (done) {
      var sql = "select * from pr where pr_status = 'O'"        +
                " order by random() limit 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        pr = res.rows[0];
        done();
      });
    });

    it("should fail with invalid pr", function (done) {
      var sql = "select releasePR($1) as result;",
          cred = _.extend({}, adminCred, { parameters: [ -1 ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "releasePR", -1);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should run without error", function (done) {
      var sql  = "select releasePR($1) as result;",
          cred = _.extend({}, adminCred, { parameters: [ pr.pr_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        poitem.poitem_id = res.rows[0].result;
        assert.operator(poitem.poitem_id, ">", 0);
        done();
      });
    });

    it("should have created a poitem", function (done) {
      var sql  = "select * from poitem where poitem_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ poitem.poitem_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        poitem = res.rows[0];
        assert.equal(poitem.poitem_status,      "U");
        assert.equal(poitem.poitem_itemsite_id, pr.pr_itemsite_id);
        assert.equal(poitem.poitem_order_id,    pr.pr_order_id);
        assert.equal(poitem.poitem_order_type,  pr.pr_order_type);
        done();
      });
    });

    it("should have deleted the pr", function (done) {
      var sql  = "select exists(select 1 from pr where pr_id = $1) as result;",
          cred = _.extend({}, adminCred, { parameters: [ pr.pr_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isFalse(res.rows[0].result);
        done();
      });
    });

    it.skip("should create purchase order if necessary");
    it.skip("should reuse existing purchase order if available");

  });

}());
