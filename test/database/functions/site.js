var _     = require("underscore"),
   assert = require('chai').assert,
   dblib  = require('../dblib');

(function () {
  "use strict";

  describe('site()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        casualCred = dblib.generateCreds('sitetest'),
        isMultiWhs = false,
        site,
        whsinfo
        ;

    it('should delete test user if it exists', function (done) {
      dblib.deleteUser(casualCred, done);
    });

    it('should create a test user', function (done) {
      dblib.createUser(casualCred, done);
    });

    it("should check available functionality", function (done) {
      var sql = "SELECT fetchMetricBool('MultiWhs') AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        isMultiWhs = res.rows[0].result;
        done();
      });
    });

    it("should be able to clean up the test user's data", function (done) {
      if (isMultiWhs) {
        var sql = "DELETE FROM usrsite WHERE usrsite_username = 'sitetest';" +
                  "DELETE FROM usrpref WHERE usrpref_username = 'sitetest';";
        datasource.query(sql, adminCred, function (err, res) {
          assert.isNull(err);
          done();
        });
      } else {
        console.log("this.skip();");
        done();
      }
    });

    it("should get rows from site()", function (done) {
      var sql = "select * from site();";
      datasource.query(sql, casualCred, function (err, res) {
        assert.isNull(err);
        site = res.rows;
        assert.operator(site.length, ">=", 1);
        done();
      });
    });

    it("should get rows from whsinfo", function (done) {
      var sql = "select * from whsinfo;";
      datasource.query(sql, casualCred, function (err, res) {
        assert.isNull(err);
        whsinfo = res.rows;
        assert.operator(whsinfo.length, ">=", 1);
        assert.operator(whsinfo.length, "==", site.length);
        done();
      });
    });

    it("should be able to set the 'selectedSites' preference", function (done) {
      var sql = "INSERT INTO usrpref ("                                 +
                " usrpref_name,    usrpref_value, usrpref_username"     +
                ") VALUES ("                                            +
                " 'selectedSites', 't',           'sitetest'"           +
                ");";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        done();
      });
    });

    it("should be able to set usrsite", function (done) {
      if (isMultiWhs) {
        var sql = "INSERT INTO usrsite ("                  +
                  " usrsite_warehous_id, usrsite_username" +
                  ") SELECT warehous_id, 'sitetest'"       +
                  "   FROM whsinfo LIMIT 1;";
        datasource.query(sql, adminCred, function (err, res) {
          assert.isNull(err);
          done();
        });
      } else {
        console.log("this.skip();");
        done();
      }
    });

    it("should enforce usrsite and selectedSites pref", function (done) {
      var sql = "select * from site();";
      datasource.query(sql, casualCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, 'only one usrsite was granted');
        done();
      });
    });

  });

}());
