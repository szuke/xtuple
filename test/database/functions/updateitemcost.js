var _ = require("underscore"),
  assert = require('chai').assert,
  path = require('path');

(function () {
  "use strict";
  describe('updateItemCost()', function () {

    var loginData = require(path.join(__dirname, "../../lib/login_data.js")).data,
      datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
      config = require(path.join(__dirname, "../../../node-datasource/config.js")),
      creds = _.extend({}, config.databaseServer, {database: loginData.org}),
      canPost = false,
      itemcostRow;

    it("should check if we have PostStandardCosts", function (done) {
      var sql = "select checkPrivilege('PostStandardCosts') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        canPost = res.rows[0].result;
        done();
      });
    });

    it("should complain if not found", function (done) {
      var sql = "select updateItemCost(-1, NULL, NULL, NULL, NULL) as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /updateitemcost.*-3[^0-9]/i);
        done();
      });
    });

    it("should get an existing itemcost", function (done) {
      var sql = "select * FROM itemcost where itemcost_actcost > 0 limit 1;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        itemcostRow = res.rows[0];
        console.log(itemcostRow);
        done();
      });
    });

    it("should reject negative cost", function (done) {
      var sql = "select updateItemCost("
              + itemcostRow.itemcost_item_id + ","
              + itemcostRow.itemcost_costelem_id
              + ", -1, NULL, NULL) as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /updateitemcost.*-4[^0-9]/i);
        done();
      });
    });

    it("should reject 0 cost", function (done) {
      var sql = "select updateItemCost("
              + itemcostRow.itemcost_item_id + ","
              + itemcostRow.itemcost_costelem_id
              + ", 0, NULL, NULL) as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /updateitemcost.*-4[^0-9]/i);
        done();
      });
    });

    it("should update an itemcost but enforce PostStandardCosts priv", function (done) {
      var sql = "select updateItemCost(" + itemcostRow.itemcost_item_id
              + ", " + itemcostRow.itemcost_costelem_id 
              + ", " + itemcostRow.itemcost_curr_id
              + ", " + (itemcostRow.itemcost_actcost * 2)
              + ", TRUE) as result";
      datasource.query(sql, creds, function (err, res) {
        if (canPost) {
          assert.isNull(err);
          assert(res.rows[0].result > 0)
        } else {
          assert.isNotNull(err);
          assert.match(err, /updateitemcost.*-5[^0-9]/i);
        }
        done();
      });
    });

  });
}());
