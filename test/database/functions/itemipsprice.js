var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('itemipsprice()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        testcases
        ;

    it("needs a variety of inputs to test", function (done) {
      var sql = "select distinct on (itemsite_costmethod, cust_custtype_id,"    +
                "                    shipto_shipzone_id)"                       +
                "       item_id, item_inv_uom_id, item_price_uom_id,"           +
                "       itemsite_warehous_id,"                                  +
                "       cust_id, cust_curr_id, shipto_id, shipto_shipzone_id,"  +
                "       saletype_id"                                            +
                "  from item     join itemsite on item_id = itemsite_id,"       +
                "       custinfo join shipto   on cust_id = shipto_cust_id,"    +
                "       saletype"                                               +
                " where item_sold   and itemsite_sold"                          +
                "   and item_active and itemsite_active"                        +
                "   and cust_active and saletype_active;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 1);
        testcases = res.rows;
        done();
      });
    });

    it("should run on a variety of items with 10 args", function (done) {
      var sql = "select *"                                      +
                "  from itemipsprice($1, $2, $3, 100,"          +
                "                    $4, $5,"                   +
                "                    $6, current_date, current_date," +
                "                    $7);";
      _.each(testcases, function (row, i) {
        var cred = _.extend({}, adminCred, { parameters: [
                              row.item_id, row.cust_id, row.shipto_id,
                              row.item_inv_uom_id, row.item_price_uom_id,
                              row.cust_curr_id,
                              row.itemsite_warehous_id
                            ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.operator(res.rowCount, ">=", 1);
          i++;
          console.log(JSON.stringify(row), "returned", res.rowCount, "rows");
          if (i >= testcases.length) { done(); }
        });
      });
    });

    it("should run on a variety of items with 10 args + shipzone",
        function (done) {
      var sql = "select *"                                      +
                "  from itemipsprice($1, $2, $3, 100,"          +
                "                    $4, $5,"                   +
                "                    $6, current_date, current_date," +
                "                    $7, $8);";
      _.each(testcases, function (row, i) {
        var cred = _.extend({}, adminCred, { parameters: [
                              row.item_id, row.cust_id, row.shipto_id,
                              row.item_inv_uom_id, row.item_price_uom_id,
                              row.cust_curr_id,
                              row.itemsite_warehous_id, row.shipto_shipzone_id
                            ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.operator(res.rowCount, ">=", 1);
          i++;
          console.log(JSON.stringify(row), "returned", res.rowCount, "rows");
          if (i >= testcases.length) { done(); }
        });
      });
    });

    it("should run on a variety of items with 10 args + shipzone + saletype",
        function (done) {
      var sql = "select *"                                      +
                "  from itemipsprice($1, $2, $3, 100,"          +
                "                    $4, $5,"                   +
                "                    $6, current_date, current_date," +
                "                    $7, $8,"                   +
                "                    $9);";
      _.each(testcases, function (row, i) {
        var cred = _.extend({}, adminCred, { parameters: [
                              row.item_id, row.cust_id, row.shipto_id,
                              row.item_inv_uom_id, row.item_price_uom_id,
                              row.cust_curr_id,
                              row.itemsite_warehous_id, row.shipto_shipzone_id,
                              row.saletype_id
                            ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.operator(res.rowCount, ">=", 1);
          i++;
          console.log(JSON.stringify(row), "returned", res.rowCount, "rows");
          if (i >= testcases.length) { done(); }
        });
      });
    });

    it.skip("should return the right price!");

  });

}());
