var DEBUG = false,
  _      = require("underscore"),
  assert = require('chai').assert,
  dblib  = require('../dblib');

(function () {
  "use strict";

  describe('postReceipt()', function () {

    var datasource = dblib.datasource,
        adminCred = dblib.generateCreds(),
        gltrans,
        pohead,
        poitem,
        recv
        ;

    var params = {
      itemNumber: "BTRUCK1",
      whCode: "WH1",
      qty: 10
    };
    var itemlocseries, numUnpostedInvHist;

    it("should fail with missing pr and no itemlocseries", function (done) {
      var sql = "select postReceipt(-1, NULL) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNotNull(err);
        done();
      });
    });

    it("needs basic G/L info", function (done) {
      var sql = "select max(gltrans_id) as gltrans_id from gltrans;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        gltrans = res.rows[0];
        done();
      });
    });

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

    it("needs a P/O receipt", function (done) {
      var sql  = "insert into recv ("                                           +
                 "  recv_order_type, recv_order_number, recv_orderitem_id,"     +
                 "  recv_itemsite_id, recv_vend_id, recv_vend_uom,"             +
                 "  recv_purchcost, recv_purchcost_curr_id, recv_duedate,"      +
                 "  recv_qty, recv_date)"                                       +
                 " select 'PO', pohead_number, poitem_id,"                      +
                 "     poitem_itemsite_id, pohead_vend_id, poitem_vend_uom,"    +
                 "     poitem_unitprice, pohead_curr_id, poitem_duedate,"       +
                 "     0, current_date"                                         +
                 "  from pohead join poitem on pohead_id = poitem_pohead_id"    +
                 " where poitem_id = $1 returning *;",
          cred = _.extend({}, adminCred, { parameters: [ params.poitemId ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        recv = res.rows;
        done();
      });
    });

    it("should fail with qty 0", function (done) {
      var sql  = "select postReceipt($1, NULL) as result;",
          cred = _.extend({}, adminCred, { parameters: [ recv[0].recv_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err);
        done();
      });
    });

    it("needs a non-0 qty", function (done) {
      var sql  = "update recv set recv_qty = 1" +
                 " where recv_id = $1 returning recv_id;",
          cred = _.extend({}, adminCred, { parameters: [ recv[0].recv_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it.skip("needs T/O receipt");
    it.skip("needs R/A receipt");

    it.skip("should fail with unknown order type", function (done) {
      var sql  = "select postReceipt($1, NULL) as result;",
          cred = _.extend({}, adminCred, { parameters: [ recv[0].recv_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNotNull(err);
        done();
      });
    });

    it.skip("needs the proper type", function (done) {
      var sql  = "update recv set recv_order_type = 'PO'" +
                 " where recv_id = $1 returning recv_id;",
          cred = _.extend({}, adminCred, { parameters: [ recv[0].recv_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should succeed for a PO item", function (done) {
      var sql  = "select postReceipt($1, NULL) as result;",
          cred = _.extend({}, adminCred, { parameters: [ recv[0].recv_id ]});
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

    it("should have updated the poitem", function (done) {
      var sql = "select poitem_qty_received from poitem where poitem_id = $1;",
         cred = _.extend({}, adminCred, { parameters: [ params.poitemId ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].poitem_qty_received, 1, "qty received earlier");
        done();
      });
    });

    it("should have updated the recv", function (done) {
      var sql = "select recv_posted from recv where recv_id = $1;",
         cred = _.extend({}, adminCred,
                         { parameters: [ recv[0].recv_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].recv_posted);
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

    it.skip("should update itemloc");
    it.skip("should honor the RecordPPVonReceipt metric");

    /*
    describe("should add test to private-extensions", function() {
      it.skip("should honor dropship");
      it.skip("should work with R/A");
      it.skip("should work with T/O");
      it.skip("should insert into rahist");
      it.skip("should insert into cohead for some R/A's");
    });
    */

  });

}());
