(function () {
  "use strict";

  var DEBUG = false,
    _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib'),
    datasource = dblib.datasource,
    adminCred = dblib.generateCreds();

  describe('postPoReturns(integer)', function () {
    this.timeout(10 * 1000);
    var params = {
      itemNumber: "BTRUCK1",
      whCode: "WH1",
      qty: 10
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

    it("needs a purchase order", function (done) {
     var callback = function (result) {  
        if (DEBUG)
          console.log("createPurchaseOrder callback result: ", result);
        params.poheadId = result;
        done();
      };
 
      dblib.createPurchaseOrder(callback);
    });

    it("needs a purchase order line item", function (done) {
     var callback = function (result) {
        if (DEBUG)
          console.log("createPurchaseOrderLineItem callback result: ", result);
        params.poitemId = result;
        done();
      };

      dblib.createPurchaseOrderLineItem(params, callback);
    });

    it("needs a po receipt", function (done) {
      var sql = "SELECT enterPoReceipt($1, $2) AS result;",
        options = _.extend({}, adminCred, { parameters: [ params.poitemId, params.qty ]});
        
      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isNotNull(res.rows[0].result);

        params.recvId = res.rows[0].result;
        done();
      });
    });

    it("should post po receipt", function (done) {
      var sql = "SELECT postItemLocSeries(postPoReceipts($1)) AS result;",
        options = _.extend({}, adminCred, { parameters: [ params.poheadId ]});
        
      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("enterPoReturn should succeed", function (done) {
      var sql  = "SELECT enterPoReturn($1, $2, (SELECT rjctcode_id FROM rjctcode LIMIT 1)) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ params.poitemId, params.qty ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].result, ">", 0);
        done();
      });
    });

    it("postPoReturns should succeed", function (done) {
      var sql  = "SELECT postPoReturns($1) as result;",
          cred = _.extend({}, adminCred, { parameters: [ params.poheadId ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        itemlocseries = res.rows[0].result;
        assert.operator(itemlocseries, ">", 0);
        done();
      });
    });

    it("needs the itemlocseries posted", function (done) {
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
        options = _.extend({}, adminCred, { parameters: [ params.itemsiteId ]});
        
      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(params.qohBefore, res.rows[0].result);
        done();
      });
    });

    it("should have updated the poitem", function (done) {
      var sql = "SELECT poitem_qty_returned AS result" +
                "  FROM poitem" + 
                " WHERE poitem_id = $1;",
         cred = _.extend({}, adminCred, { parameters: [ params.poitemId ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, params.qty, "qty returned matches qty received earlier");
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
