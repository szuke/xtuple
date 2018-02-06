var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('_setPackageIsEnabled()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        testPkgName = 'testPackage' + Date.now(), //Date.now().valueOf()?
        testPkgId
        ;

    it("needs a package to test with", function (done) {
      var sql = "SELECT createpkgschema($1, 'test enabling and disabling of extension schemas') AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgName ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("needs the pkghead_id", function (done) {
      var sql = "SELECT pkghead_id FROM pkghead WHERE pkghead_name = LOWER($1);",
          cred = _.extend({}, adminCred, { parameters: [ testPkgName ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        testPkgId = res.rows[0].pkghead_id;
        done();
      });
    });

    it("needs an extra table", function (done) {
      var sql = "SELECT xt.create_table('testTab', $1) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgName ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("test table needs a column", function (done) {
      var sql = "SELECT xt.add_column('testTab', 'testTab_integer', 'INTEGER', NULL, $1) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgName ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("needs a trigger function", function (done) {
      var sql = "CREATE OR REPLACE FUNCTION _publicTrigger() RETURNS TRIGGER AS $$ BEGIN RAISE NOTICE 'entered with %', TG_OP; RETURN NEW; END; $$ LANGUAGE plpgsql;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        done();
      });
    });

    it("needs a trigger", function (done) {
      var sql = "CREATE TRIGGER publicTrigger"
              + " BEFORE INSERT ON " + testPkgName + ".testTab"
              + " FOR EACH ROW EXECUTE PROCEDURE _publicTrigger();";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        done();
      });
    });

    it("should fail with non-existent package name", function (done) {
      var sql = "select _setPackageIsEnabled('thispackagedoesnotexist', true) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNotNull(err);
        done();
      });
    });

    it("should fail with non-existent package id", function (done) {
      var sql = "SELECT _setPackageIsEnabled(-1, TRUE) AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNotNull(err);
        done();
      });
    });

    it("should disable a package by name", function (done) {
      var sql  = "SELECT _setPackageIsEnabled($1, FALSE) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgName ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should enable a package by name", function (done) {
      var sql  = "SELECT _setPackageIsEnabled($1, TRUE) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgName ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should disable a package by id", function (done) {
      var sql  = "SELECT _setPackageIsEnabled($1::INTEGER, FALSE) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgId ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should disable an already-disabled package by id", function (done) {
      var sql  = "SELECT _setPackageIsEnabled($1::INTEGER, TRUE) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgId ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should disable an already-disabled package by name", function (done) {
      var sql  = "SELECT _setPackageIsEnabled($1, TRUE) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgName ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it.skip("should not execute the public trigger when the package is disabled");
    it.skip("should not execute a package trigger on a public table when the package is disabled");

    it("should enable a package by id", function (done) {
      var sql  = "SELECT _setPackageIsEnabled($1::INTEGER, TRUE) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgId ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should enable an already-enabled package by id", function (done) {
      var sql  = "SELECT _setPackageIsEnabled($1::INTEGER, TRUE) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgId ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should enable an already-enabled package by name", function (done) {
      var sql  = "SELECT _setPackageIsEnabled($1, TRUE) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgName ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("need to clean up afterward", function (done) {
      var sql  = "SELECT deletePackage($1) AS result;",
          cred = _.extend({}, adminCred, { parameters: [ testPkgId ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

  });

}());
