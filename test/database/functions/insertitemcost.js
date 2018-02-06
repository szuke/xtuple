var _ = require("underscore"),
  assert = require('chai').assert,
  path = require('path');

(function () {
  "use strict";
  describe('insertItemCost()', function () {

    var loginData = require(path.join(__dirname, "../../lib/login_data.js")).data,
      datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
      config = require(path.join(__dirname, "../../../node-datasource/config.js")),
      creds = _.extend({}, config.databaseServer, {database: loginData.org}),
      canPost = false,
      mfgItemId  = -1,
      purItemId  = -1;

    it("should check if we have PostStandardCosts", function (done) {
      var sql = "select checkPrivilege('PostStandardCosts') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        canPost = res.rows[0].result;
        done();
      });
    });

    it("should reject null cost", function (done) {
      var sql = "select insertItemCost(NULL, NULL, NULL, NULL, NULL) as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /insertitemcost.*-4[^0-9]/i);
        done();
      });
    });

    it("should reject negative cost", function (done) {
      var sql = "select insertItemCost(-1, NULL, NULL, NULL, NULL) as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /insertitemcost.*-4[^0-9]/i);
        done();
      });
    });

    it("should reject 0 cost", function (done) {
      var sql = "select insertItemCost(0, NULL, NULL, NULL, NULL) as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /insertitemcost.*-4[^0-9]/i);
        done();
      });
    });

    it("should reject existing cost", function (done) {
      var sql = "select insertItemCost(itemcost_item_id, itemcost_costelem_id, itemcost_curr_id, itemcost_actcost, TRUE) as result"
              + "  FROM itemcost limit 1;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /insertitemcost.*-3[^0-9]/i);
        done();
      });
    });

    it("should reject mismatched item_type,costelem_type for Manufactured items", function (done) {
      var sql = "select insertItemCost(item_id, costelem_id, basecurrid(), 1.23, TRUE) as result"
              + "  from item, costelem"
              + " where item_type in ('M', 'F', 'B', 'C', 'T')"
              + "   and costelem_type = 'Material'"
;
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /insertitemcost.*-5[^0-9]/i);
        done();
      });
    });

    it("should reject mismatched item_type,costelem_type for purchased items", function (done) {
      var sql = "select insertItemCost(item_id, costelem_id, basecurrid(), 1.23, TRUE) as result"
              + "  from item, costelem"
              + " where item_type in ('O', 'P')"
              + "   and costelem_type in ('Direct Labor', 'Overhead', 'Machine Overhead')"
;
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /insertitemcost.*-6[^0-9]/i);
        done();
      });
    });

    it("should get a manufactured item with no cost elements", function (done) {
      var sql = "select item_id, item_type from item"
              + " where item_type = 'M'"
              + "   and item_id not in (select itemcost_item_id from itemcost);";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount > 0);
        mfgItemId = res.rows[0].item_id;
        console.log("Manufactured: " + mfgItemId);
        done();
      });
    });

    it("should get a purchased item with no cost elements", function (done) {
      var sql = "select item_id, item_type from item"
              + " where item_type = 'P'"
              + "   and item_id not in (select itemcost_item_id from itemcost);";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount > 0);
        purItemId = res.rows[0].item_id;
        console.log("Purchased: " + purItemId);
        done();
      });
    });

    it("should insert mfg item with valid cost elem but enforce PostStandardCosts priv", function (done) {
      var sql = "select insertItemCost(" + mfgItemId
              + ", costelem_id, basecurrid(), 1.23, TRUE) as result"
              + " from costelem where costelem_type = 'Direct Labor';" ;
      datasource.query(sql, creds, function (err, res) {
        if (canPost) {
          assert.isNull(err);
          assert(res.rows[0].result > 0)
        } else {
          assert.isNotNull(err);
          assert.match(err, /insertitemcost.*-7[^0-9]/i);
        }
        done();
      });
    });

    it("should insert purchased item with valid cost elem but enforce PostStandardCosts priv", function (done) {
      var sql = "select insertItemCost(" + purItemId
              + ", costelem_id, basecurrid(), 1.23, TRUE) as result"
              + " from costelem where costelem_type = 'Material';" ;
      datasource.query(sql, creds, function (err, res) {
        if (canPost) {
          assert.isNull(err);
          assert(res.rows[0].result > 0)
        } else {
          assert.isNotNull(err);
          assert.match(err, /insertitemcost.*-7[^0-9]/i);
        }
        done();
      });
    });

  });
}());
