var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('getItemsiteId()', function () {
    var datasource = dblib.datasource,
        adminCred = dblib.generateCreds(),
        item,
        whs
        ;

    it("needs a list of warehouses", function (done) {
      var sql = "select warehous_id, warehous_code from whsinfo;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, '>=', 1);
        whs = res.rows;
        done();
      });
    });

    it("needs some sample items", function (done) {
      var sql = "with mainquery as ("                                           +
                "select min(item_id) as item_id, item_active, item_sold,"       +
                "       min(itemsite_id) as itemsite_id, itemsite_active,"      +
                "       itemsite_sold, warehous_id"                             +
                "  from item"                                                   +
                "  left outer join itemsite on item_id = itemsite_item_id"      +
                "  left outer join whsinfo on itemsite_warehous_id=warehous_id" +
                " group by item_active, item_sold,"                             +
                "          itemsite_active, itemsite_sold, warehous_id)"        +
                "select mainquery.*, item_number from"                          +
                " mainquery join item i on mainquery.item_id = i.item_id;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, '>=', 1);
        item = res.rows;
        done();
      });
    });

    it("should work with 2 args", function (done) {
      var sql = "select getItemsiteId($1, $2) as result;",
          i   = _.find(item, function (e) { return e.itemsite_id && e.warehous_id; }),
          w   = _.find(whs, function (e) { return e.warehous_id === i.warehous_id; }),
          cred = _.extend({}, adminCred,
                          { parameters: [ w.warehous_code, i.item_number ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, i.itemsite_id);
        done();
      });
    });

    _.each(['ALL', 'ACTIVE', 'SOLD', 'INVALID'], function (type) {
      var sql   = "select getItemsiteId($1, $2, $3) as result;";

      it("should return null if warehouse is null for " + type, function (done) {
        var cred = _.extend({}, adminCred,
                        { parameters: [ null, item[0].item_number, type ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.isNull(res.rows[0].result);
          done();
        });
      });

      it("should return null for null item and " + type, function (done) {
        var cred = _.extend({}, adminCred,
                        { parameters: [ whs[0].warehous_code, null, type ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.isNull(res.rows[0].result);
          done();
        });
      });
    });

    _.each(['ALL', 'ACTIVE', 'SOLD', 'INVALID'], function (type) {
      _.each([false, true], function (haswhs) {
        _.each([false, true], function (isactive) {
          _.each([false, true], function (issold) {
            it("should handle " + type + ", " +
                (haswhs   ? "has" : "no" ) + " whs, "    +
                (isactive ? "is"  : "not") + " active, " +
                (issold   ? "is"  : "not") + " sold", function(done) {
              var sql   = "select getItemsiteId($1, $2, $3) as result;",
                  exp   = "error",
                  cred, i, w;
              i = _.find(item, function (e) {
                return isactive === (e.item_active || e.itemsite_active) &&
                       issold   === (e.item_sold   || e.itemsite_sold)   &&
                       haswhs   === (e.warehous_id !== null);
              });
              if (i) {
                w = _.find(whs,
                      function (e) { return e.warehous_id === i.warehous_id; });
                cred = _.extend({}, adminCred,
                                { parameters: [ w && w.warehous_code,
                                                i.item_number, type ] });
                if (! w) {
                  exp = null;
                } else if (type === 'ALL' ||
                    (type === 'ACTIVE' && i.item_active && i.itemsite_active) ||
                    (type === 'SOLD'   && i.item_sold   && i.itemsite_sold &&
                                          i.item_active && i.itemsite_active)) {
                  exp = i.itemsite_id;
                }
                datasource.query(sql, cred, function (err, res) {
                  if (exp === "error") {
                    assert.isNotNull(err);
                  } else {
                    assert.isNull(err);
                    assert.equal(res.rowCount, 1);
                    assert.equal(res.rows[0].result, exp);
                  }
                  done();
                });
              } else {
                console.log("don't have data to support this case");
                done();
              }
            });
          });
        });
      });
    });

  });
})();
