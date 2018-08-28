var _ = require("underscore"),
  assert = require('chai').assert;

(function () {
  "use strict";

  var dblib = require('../dblib');

  describe('changePurchaseDropShip()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        poitem,
        ponumber
        ;

    it.skip("should ensure there's an open po", function (done) {
      var sql = "insert into api.purchaseorder ("               +
                "  order_number, vendor_number, alt_address,"   +
                "  sales_order_number"                          +
                ") select fetchPONumber(), vend_number, 'MAIN'" +
                "    from vendinfo"                             +
                "    join cohead on vend_id = cohead_vend_id"   +
                "   where cohead_status = 'O'"                  +
                "     and cohead_id in (select coitem_cohead_id"+
                "                         from coitem"          +
                "                        where item is purchased)" +
                " limit 1 returning order_number;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        ponumber = res.rows[0].order_number;
        done();
      });
    });

    it.skip("should ensure there's an open poitem", function (done) {
      var sql = "insert into api.purchaseline ("                +
                "  order_number, line_number, due_date,"        +
                "  item_number, qty_ordered"                    +
                ") select $1, 1, current_date,"                 +
                "         item_number, 15"                      +
                "    from item where item_type = 'P' limit 1"   +
                " returning order_number;",
          cred = _.extend({}, adminCred, { parameters: [ ponumber ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should find a drop-ship po", function (done) {
      var sql = "select poitem.*, pohead_status"                +
                "  from poitem"                                 +
                "  join pohead on poitem_pohead_id = pohead_id" +
                "  where poitem_order_type = 'S';";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, '>=', 1);
        poitem = res.rows;
        done();
      });
    });

    it("should return error with invalid po and coitems", function (done) {
      var sql = "select changePurchaseDropShip(-1, -1, false) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.match(err, /changepurchasedropship.*-2/);
        done();
      });
    });

    it("should return error with invalid poitem", function (done) {
      var sql = "select changePurchaseDropShip($1, $2, false) as result",
          cred = _.extend({}, adminCred,
                          { parameters: [ poitem[0].poitem_order_id, -1 ] });
      datasource.query(sql, cred, function (err, res) {
        assert.match(err, /changepurchasedropship.*-2/);
        done();
      });
    });

    it("should return error with invalid coitem", function (done) {
      var sql = "select changePurchaseDropShip($1, $2, false) as result",
          cred = _.extend({}, adminCred,
                          { parameters: [ -1, poitem[0].poitem_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.match(err, /changepurchasedropship.*-[1-9]/);
        done();
      });
    });

    it.skip("should return error when cohead is missing", function (done) {
      /* how do we generate this case? */
      var sql = "select changePurchaseDropShip($1, $2, false) as result",
          cred = _.extend({}, adminCred,
                          { parameters: [ poitem[0].poitem_order_id,
                                          poitem[0].poitem_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.match(err, /changepurchasedropship.*-1]/);
        done();
      });
    });

    it("should return error with bad order status", function (done) {
      var sql = "select changePurchaseDropShip($1, $2, false) as result",
          notU = _.find(poitem, function (e) { return e.pohead_status!=='U'; }),
          cred = _.extend({}, adminCred,
                          { parameters: [ notU.poitem_order_id,
                                          notU.poitem_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.match(err, /changepurchasedropship.*-[1-9]/);
        done();
      });
    });

    it("should return positive int on success with 'false'", function (done) {
      var sql = "select changePurchaseDropShip($1, $2, false) as result",
          isU = _.find(poitem, function (e) { return e.pohead_status==='U'; }),
          cred;

      if (isU) {
        cred = _.extend({}, adminCred,
                        { parameters: [ isU.poitem_order_id, isU.poitem_id ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].result, '>=', 0);
          done();
        });
      } else {
        console.log("could not test");
        done();
      }
    });

    it("should return positive int on success with 'true'", function (done) {
      var sql = "select changePurchaseDropShip($1, $2, true) as result",
          isU = _.find(poitem, function (e) { return e.pohead_status==='U'; }),
          cred;
      
      if (isU) {
        cred = _.extend({}, adminCred,
                        { parameters: [ isU.poitem_order_id, isU.poitem_id ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].result, '>=', 0);
          done();
        });
      } else {
        console.log("could not test");
        done();
      }
    });

  });

}());
