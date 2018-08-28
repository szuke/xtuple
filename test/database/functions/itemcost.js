var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('itemCost()', function () {

    var datasource = dblib.datasource,
        adminCred = dblib.generateCreds();

    it("should return null with non-existent itemsite", function (done) {
      var sql = "select itemCost(-15) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isNull(res.rows[0].result, "return value");
        done();
      });
    });

    it("should return a cost for existing itemsites", function (done) {
      var sql = "select itemCost(min(itemsite_id)) as cost, item_type,"         +
                "       itemsite_costmethod, itemsite_qtyonhand = 0 as isEmpty" +
                "  from itemsite join item on itemsite_item_id = item_id"       +
                " group by itemsite_costmethod, isEmpty, item_type;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 1);
        _.each(res.rows, function (row) {
          var context = "cost method: " + row.itemsite_costmethod +
                        "  item type: " + row.item_type;
          if (row.itemsite_costmethod === 'N' && row.item_type !== 'K') {
            assert.equal(row.cost, 0, context);
          } else {
            assert.operator(row.cost, ">=", 0, context);
          }
        });
        done();
      });
    });

    it("should succeed with 10 args", function (done) {
      var sql = "select distinct on (itemsite_costmethod, isEmpty)"             +
                "       item_type,"                                             +
                "       itemCost(item_id, cust_id, shipto_id, 5,"               +
                "                item_inv_uom_id, item_price_uom_id,"           +
                "                cust_curr_id, current_date, current_date,"     +
                "                itemsite_warehous_id) as cost,"                +
                "       itemsite_costmethod, itemsite_qtyonhand = 0 as isEmpty" +
                "  from item     join itemsite on item_id = itemsite_item_id,"  +
                "       custinfo join shipto   on cust_id = shipto_cust_id"     +
                " where item_sold   and itemsite_sold"                          +
                "   and item_active and itemsite_active and cust_active;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 1);
        _.each(res.rows, function (row) {
          var context = "cost method: " + row.itemsite_costmethod +
                        "  item type: " + row.item_type;
          if (row.itemsite_costmethod === 'N' && row.item_type !== 'K') {
            assert.equal(row.cost, 0, context);
          } else {
            assert.operator(row.cost, ">=", 0, context);
          }
        });
        done();
      });
    });

    it("should succeed with 10 args + true", function (done) {
      var sql = "select distinct on (itemsite_costmethod, isEmpty, item_type)"  +
                "       item_type,"                                             +
                "       itemCost(item_id, cust_id, shipto_id, 5,"               +
                "                item_inv_uom_id, item_price_uom_id,"           +
                "                cust_curr_id, current_date, current_date,"     +
                "                itemsite_warehous_id, true ) as cost,"         +
                "       itemsite_costmethod, itemsite_qtyonhand = 0 as isEmpty" +
                "  from item     join itemsite on item_id = itemsite_item_id,"  +
                "       custinfo join shipto   on cust_id = shipto_cust_id"     +
                " where item_sold   and itemsite_sold"                          +
                "   and item_active and itemsite_active and cust_active;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 1);
        _.each(res.rows, function (row) {
          var context = "cost method: " + row.itemsite_costmethod +
                        "  item type: " + row.item_type;
          if (row.itemsite_costmethod === 'N' && row.item_type !== 'K') {
            assert.equal(row.cost, 0, context);
          } else {
            assert.operator(row.cost, ">=", 0, context);
          }
        });
        done();
      });
    });

    it("should succeed with 10 args + false", function (done) {
      var sql = "select distinct on (itemsite_costmethod, isEmpty, item_type)"  +
                "       item_type,"                                             +
                "       itemCost(item_id, cust_id, shipto_id, 5,"               +
                "                item_inv_uom_id, item_price_uom_id,"           +
                "                cust_curr_id, current_date, current_date,"     +
                "                itemsite_warehous_id, false) as cost,"         +
                "       itemsite_costmethod, itemsite_qtyonhand = 0 as isEmpty" +
                "  from item     join itemsite on item_id = itemsite_item_id,"  +
                "       custinfo join shipto   on cust_id = shipto_cust_id"     +
                " where item_sold   and itemsite_sold"                          +
                "   and item_active and itemsite_active and cust_active;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 1);
        _.each(res.rows, function (row) {
          var context = "cost method: " + row.itemsite_costmethod +
                        "  item type: " + row.item_type;
          if (row.itemsite_costmethod === 'N' && row.item_type !== 'K') {
            assert.equal(row.cost, 0, context);
          } else {
            assert.operator(row.cost, ">=", 0, context);
          }
        });
        done();
      });
    });

  });

}());
