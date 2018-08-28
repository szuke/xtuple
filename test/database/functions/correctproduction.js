(function () {
  "use strict";

  var DEBUG = false,
    _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib'),
    datasource = dblib.datasource,
    adminCred = dblib.generateCreds();

  // TODO - write tests for all the other versions of correctProduction()

  describe("correctProduction(integer, numeric, boolean, integer, timestamp with time zone, integer, boolean)", function () {
    this.timeout(10 * 1000);

    var params = {
      itemNumber: "BTRUCK1",
      whCode: "WH1",
      qty: 100
    };
    var itemlocseries, numUnpostedInvHist;

    it("needs the itemsite_id and qoh",function (done) {
      var sql = "SELECT itemsite_qtyonhand, itemsite_id" +
                "  FROM itemsite" +
                " WHERE itemsite_id = getitemsiteid($1, $2);",
        options = _.extend({}, adminCred, { parameters: [ params.whCode, params.itemNumber ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
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

    it("needs an open work order", function (done) {
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
          console.log("explodeWo() result: ", res.rows[0].result);
        
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].result, ">", 0);
        done();
      });
    });

    it("needs production and any inventory transactions posted", function (done) {
      var sql = "SELECT postItemLocSeries(postProduction($1::integer, $2::numeric,"
              + "                                        true, NULL, NOW())) AS result;",
        options = _.extend({}, adminCred, { parameters: [ params.woId, params.qty ]});

      datasource.query(sql, options, function (err, res) {
        if (DEBUG)
          console.log("postProduction() result: ", res.rows[0].result);
        
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

    it.skip("should fail if itemsite missing cost category", function (done) {
    });

    it.skip("should fail with WO status 'I'", function (done) {
    });

    it.skip("should fail if Job costed item", function (done) {
    });

    // Note: Don't handle distribution detail here, that will be done in private-extensions/test/manufacturing

    it("should succeed with backflush", function (done) {
      var sql = "SELECT correctproduction($1::integer, 1::numeric, TRUE, NULL::integer, NOW(), NULL::integer, FALSE) AS result;",
        options = _.extend({}, adminCred, { parameters: [ params.woId ]});

      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        itemlocseries = res.rows[0].result;
        assert.operator(itemlocseries, ">", 0);
        done();
      });
    });

    it("needs the backflush itemlocseries posted", function (done) {
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
        assert.equal(res.rows[0].result, params.qty -1);
        done();
      });
    });

    it("should succeed without backflush", function (done) {
      var sql = "SELECT correctproduction($1::integer, 1, FALSE, NULL, NOW(), NULL, FALSE) AS result;",
        options = _.extend({}, adminCred, { parameters: [ params.woId ]});

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
        assert.equal(res.rows[0].result, params.qty -2);
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

