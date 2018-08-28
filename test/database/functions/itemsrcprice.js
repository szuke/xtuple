var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe.skip('itemsrcprice()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds()
        ;

    it.skip("with no args should return without error", function (done) {
      var sql = "select itemsrcprice() as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });

  });

}());
