var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('addrUseCount()', function () {
    this.timeout(5 * 1000);

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        addr       = {},
        added      = []
        ;

    it("should return a value for an address in use", function (done) {
      var sql = "SELECT cntct_addr_id, COUNT(*) AS count,"        +
                "       addrUseCount(cntct_addr_id) AS usecount"  +
                "  FROM cntct"                                    +
                " WHERE cntct_addr_id IS NOT NULL"                +
                " GROUP BY cntct_addr_id;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 0);
        _.each(res.rows, function (e) {
          addr[e.cntct_addr_id] = e.count;
          assert.operator(e.usecount, ">=", e.count);
        });
        done();
      });
    });

    it("needs a new association to count", function (done) {
      var sql = "UPDATE cntct SET cntct_addr_id = $1"   +
                " WHERE cntct_addr_id IS NULL"          +
                " RETURNING cntct_id;",
          cred = _.extend({}, adminCred, { parameters: [] }),
          i;
      for (i in addr)
        if (i != "null")
          break;
      cred.parameters.push(addr[i]);
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 0);
        _.each(res.rows, function (e) {
          added.push(e.cntct_id);
        });
        added.addr_id = i;
        done();
      });
    });
    
    it("should return an updated count", function (done) {
      var sql = "SELECT addrUseCount($1) AS usecount;",
          cred = _.extend({}, adminCred, { parameters: [ added.addr_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].usecount, addr[added.addr_id] + added.length);
        done();
      });
    });

    it("needs to clean up afterward", function (done) {
      var sql = "UPDATE cntct SET cntct_addr_id = NULL"         +
                " WHERE cntct_id IN (" + added.join(", ") + ")" +
                " RETURNING cntct_id;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, added.length);
        done();
      });
    });

  });

}());
