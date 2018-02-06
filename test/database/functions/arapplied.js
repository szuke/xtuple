var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('arapplied()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds()
        ;

    it("should return 0 for a non-existent aropen id", function (done) {
      var sql = "SELECT arapplied(-5, CURRENT_DATE) AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0.0);
        done();
      });
    });

    it("should return 0 for a very old date", function (done) {
      var sql = "SELECT arapplied(aropen_id, '1970-01-01'::DATE) AS result" +
                "  FROM aropen LIMIT 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0.0);
        done();
      });
    });
    
    it("should return non-0 for an aropen with applications", function (done) {
      var sql = "SELECT arapplied(arapply_target_aropen_id,"    +
                "                 CURRENT_DATE) AS result,"     +
                "       arapply_target_aropen_id"               +
                "  FROM arapply"                                +
                " WHERE arapply_postdate <= CURRENT_DATE"       +
                " LIMIT 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.notEqual(res.rows[0].result, 0);
        done();
      });
    });

    it.skip("should determine that the correct value is returned!");

  });

}());
