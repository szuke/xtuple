var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('apapplied()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds()
        ;

    it("should return 0 for a non-existent apopen id", function (done) {
      var sql = "SELECT apapplied(-5, CURRENT_DATE) AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0.0);
        done();
      });
    });

    it("should return 0 for a very old date", function (done) {
      var sql = "SELECT apapplied(apopen_id, '1970-01-01'::DATE) AS result" +
                "  FROM apopen LIMIT 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0.0);
        done();
      });
    });
    
    it("should return non-0 for an apopen with applications", function (done) {
      var sql = "SELECT apapplied(apapply_target_apopen_id,"    +
                "                 CURRENT_DATE) AS result,"     +
                "       apapply_target_apopen_id"               +
                "  FROM apapply"                                +
                " WHERE apapply_postdate <= CURRENT_DATE"       +
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
