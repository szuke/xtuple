var _      = require("underscore"),
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

    it("needs a P/O to receive against", function (done) {
      var sql = "insert into pohead ("                                  +
                "  pohead_status, pohead_number, pohead_orderdate,"     +
                "  pohead_vend_id, pohead_comments, pohead_terms_id,"   +
                "  pohead_curr_id, pohead_taxzone_id"                   +
                ") select 'O', fetchPONumber(), current_date,"          +
                "         vend_id, 'test postreceipt', vend_terms_id,"  +
                "         basecurrid(), vend_taxzone_id"                +
                "    from vendinfo where vend_active limit 1"           +
                " returning *;",
          cred = _.extend({}, adminCred);
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        pohead = res.rows[0];
        sql  = "insert into poitem ("                                   +
               "  poitem_status, poitem_pohead_id, poitem_linenumber,"  +
               "  poitem_duedate, poitem_itemsite_id,"                  +
               "  poitem_qty_ordered, poitem_unitprice"                 +
               ") select 'O', $1, 1,"                                   +
               "         current_date + interval '1 day', itemsite_id," +
               "         case itemsite_ordertoqty when 0 then 10"       +
               "              else itemsite_ordertoqty end,"            +
               "         item_listprice"                                +
               "    from itemsite"                                      +
               "    join item on itemsite_item_id = item_id"            +
               "   where itemsite_sold and item_sold"                   +
               "     and itemsite_active and item_active"               +
               "   limit 1"                                             +
               " returning *;";
        cred = _.extend(cred, { parameters: [ pohead.pohead_id ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          poitem = res.rows[0];
          done();
        });
      });
    });

    it("needs that PO to be open", function (done) {
      var sql  = "select releasePurchaseOrder($1) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ poitem.poitem_pohead_id ] });
      if (poitem.poitem_status === 'U') {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].result, 1, "released the PO");
          done();
        });
      } else {
        done();
      }
    });

    // just P/O for now
    it("needs a receipt", function (done) {
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
          cred = _.extend({}, adminCred, { parameters: [ poitem.poitem_id ] });
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
        assert.operator(res.rows[0].result, ">", 0);
        done();
      });
    });

    it("should have updated the poitem", function (done) {
      var sql = "select poitem_qty_received from poitem where poitem_id = $1;",
         cred = _.extend({}, adminCred, { parameters: [ poitem.poitem_id ]});
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

    it.skip("should post inventory transactions");
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
