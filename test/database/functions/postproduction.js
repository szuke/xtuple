(function () {
  "use strict";

  var DEBUG = false,
    _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib'),
    datasource = dblib.datasource,
    adminCred = dblib.generateCreds();

  // TODO - write unit tests for the other versions of postProduction()

  describe("postProduction(integer, qty, boolean, integer, timestamp with time zone, boolean, boolean", function () {
    this.timeout(10 * 1000);

    var params = {
      itemNumber: "BTRUCK1",
      whCode: "WH1",
      qty: 10
    };
    var itemlocseries, numUnpostedInvHist;

    it("needs the wo itemsite_id and qoh",function (done) {
      var sql = "SELECT itemsite_qtyonhand, itemsite_id" +
                "  FROM itemsite" +
                " WHERE itemsite_id = getitemsiteid($1, $2);",
        options = _.extend({}, adminCred, { parameters: [ params.whCode, params.itemNumber ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].itemsite_id, ">", 0);

        params.itemsiteId = res.rows[0].itemsite_id;
        params.qohBefore = res.rows[0].itemsite_qtyonhand;

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
          console.log("dblib.createWorkOrder callback result: ", result);

        params.woId = result;

        var sql = "UPDATE wo SET wo_status = 'O' WHERE wo_id = $1::integer;",
          options = _.extend({}, adminCred, { parameters: [ params.woId ]});

        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          done();
        });
      };

      dblib.createWorkOrder(params, callback);
    });

    it("explodeWo() should succeed", function (done) {
      var sql = "SELECT explodeWo($1::integer, false) AS result;",
        options = _.extend({}, adminCred, { parameters: [ params.woId ]});

      datasource.query(sql, options, function (err, res) {
        if (DEBUG)
          console.log("postProduction explodeWo result: ", res.rows[0].result);

        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].result, ">", 0);
        done();
      });
    });

    it.skip("should fail pPreDistributed and pItemlocSeries null");
    it.skip("should not proceed if qty < 0");
    it.skip("should fail itemsite has no cost category");

    // Note: Don't handle distribution detail here, that will be done in private-extensions/test/manufacturing

    it("postProduction() without backflush should succeed", function (done) {
      var sql = "SELECT postProduction($1, $2, FALSE, NULL, now(), false, true) AS result;",
        options = _.extend({}, adminCred, { parameters: [ params.woId, params.qty ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        itemlocseries = res.rows[0].result;
        assert.operator(itemlocseries, ">", 0);
        done();
      });
    });

    it("needs the non-backflush itemlocseries posted", function (done) {
      var sql     = "SELECT postItemLocSeries($1) AS result;",
          options = _.extend({}, adminCred, { parameters: [ itemlocseries ]});
      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("should have updated wo_qtyrcv", function (done) {
      var sql = "SELECT wo_qtyrcv AS result" +
                "  FROM wo" +
                " WHERE wo_id=$1::integer;",
        options = _.extend({}, adminCred, { parameters: [ params.woId ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, params.qty);

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

