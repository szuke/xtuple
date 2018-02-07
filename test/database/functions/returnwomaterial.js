(function () {
  "use strict";

  var DEBUG = false,
    _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib'),
    datasource = dblib.datasource,
    adminCred = dblib.generateCreds();

  //describe.skip("returnWoMaterial(integer, numeric, timestamp with timezone)");
  //describe.skip("returnWoMaterial(integer, integer, timestamp with timezone, integer)");

  describe("returnWoMaterial(integer, qty, integer, tiemstamp with time zone, boolean, boolean, boolean)", function () {
    this.timeout(10 * 1000);

    var woParams = {
      itemNumber: "BTRUCK1",
      whCode: "WH1",
      qty: 10
    };

    var womatlParams = {
      itemNumber: "TBODY1",
      whCode: "WH1",
      qty: 1
    };
    var itemlocseries, numUnpostedInvHist;

    it("should get the womatl itemsite_id and qoh",function (done) {
      var sql = "SELECT itemsite_qtyonhand, itemsite_id" +
                "  FROM itemsite" +
                " WHERE itemsite_id = getitemsiteid($1, $2);",
        options = _.extend({}, adminCred, { parameters: [ womatlParams.whCode, womatlParams.itemNumber ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].itemsite_id, ">", 0);
        womatlParams.itemsiteId = res.rows[0].itemsite_id;
        womatlParams.qohBefore = res.rows[0].itemsite_qtyonhand;
        done();
      });
    });

    it("should get the wo itemsite_id and qoh",function (done) {
      var sql = "SELECT itemsite_qtyonhand, itemsite_id" +
                "  FROM itemsite" +
                " WHERE itemsite_id = getitemsiteid($1, $2);",
        options = _.extend({}, adminCred, { parameters: [ woParams.whCode, woParams.itemNumber ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].itemsite_id, ">", 0);
        woParams.itemsiteId = res.rows[0].itemsite_id;
        woParams.qohBefore = res.rows[0].itemsite_qtyonhand;
        done();
      });
    });

    it("needs the number of unposted invhist records", function (done) {
      var sql = "SELECT COUNT(*) AS num FROM invhist WHERE NOT invhist_posted;";

      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        numUnpostedInvHist = res.rows[0].num;
        done();
      });
    });

    it("needs a work order", function (done) {
      var callback = function (result) {
        if (DEBUG)
          console.log("createWorkOrder callback result: ", result);

        woParams.woId = result;
        done();
      };

      dblib.createWorkOrder(woParams, callback);
    });

    it("explodeWo() should succeed", function (done) {
      var sql = "SELECT explodeWo($1::integer, false) AS result;",
        options = _.extend({}, adminCred, { parameters: [ woParams.woId ]});

      datasource.query(sql, options, function (err, res) {
        if (DEBUG)
          console.log("returnWoMaterial explodeWo result: ", res.rows[0].result);
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].result, ">", 0);
        done();
      });
    });

    // Note: Don't handle distribution detail here, that will be done in private-extensions/test/manufacturing

    it("issueWoMaterial() should succeed", function (done) {
      var sql = "SELECT issueWoMaterial(womatl_id, $1::numeric, NULL::integer, NOW(), NULL::integer, NULL::numeric, false, true) AS result " +
                "  FROM womatl " +
                " WHERE womatl_wo_id = $2::integer " +
                "   AND womatl_itemsite_id = $3::integer;",
        options = _.extend({}, adminCred, { parameters: [ womatlParams.qty, woParams.woId, womatlParams.itemsiteId ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        itemlocseries = res.rows[0].result;
        assert.operator(itemlocseries, ">", 0);
        done();
      });
    });

    it("needs the issueWoMaterial itemlocseries posted", function (done) {
      var sql     = "SELECT postItemLocSeries($1) AS result;",
          options = _.extend({}, adminCred, { parameters: [ itemlocseries ]});
      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("should have updated qoh", function (done) {
      var sql = "SELECT itemsite_qtyonhand AS result" +
                "  FROM itemsite" +
                " WHERE itemsite_id=$1::integer;",
        options = _.extend({}, adminCred, { parameters: [ womatlParams.itemsiteId ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, (womatlParams.qohBefore - womatlParams.qty));
        done();
      });
    });

    it.skip("returnWoMaterial(integer, qty, integer, tiemstamp with time zone, boolean, boolean, boolean) should fail if pPreDistributed and no pItemlocSeries");

    // Note: Don't handle distribution detail here, that will be done in private-extensions/test/manufacturing

    it("returnWoMaterial(integer, qty, integer, tiemstamp with time zone, boolean, boolean, boolean) should succeed", function (done) {
      var sql = "SELECT returnWoMaterial(womatl_id, $1::numeric, NULL::integer, NOW(), FALSE, FALSE, TRUE) AS result " +
                "  FROM womatl " +
                " WHERE womatl_wo_id = $2::integer " +
                "   AND womatl_itemsite_id = $3::integer;",
        options = _.extend({}, adminCred, { parameters: [ womatlParams.qty, woParams.woId, womatlParams.itemsiteId ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        itemlocseries = res.rows[0].result;
        assert.operator(itemlocseries, ">", 0);
        done();
      });
    });

    it("needs the returnWoMaterial itemlocseries posted", function (done) {
      var sql     = "SELECT postItemLocSeries($1) AS result;",
          options = _.extend({}, adminCred, { parameters: [ itemlocseries ]});
      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("should have updated qoh", function (done) {
      var sql = "SELECT itemsite_qtyonhand AS result" +
                "  FROM itemsite" +
                " WHERE itemsite_id=$1::integer;",
        options = _.extend({}, adminCred, { parameters: [ womatlParams.itemsiteId ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(+womatlParams.qohBefore, res.rows[0].result);
        done();
      });
    });

    it("there should be no new unposted invhist records", function (done) {
      var sql = "SELECT COUNT(*) AS num FROM invhist WHERE NOT invhist_posted;";

      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].num, numUnpostedInvHist);
        done();
      });
    });

  });
}());

