var _ = require("underscore"),
    assert = require('chai').assert,
    path   = require('path');

(function () {
  "use strict";
  describe('setUserPreference()', function () {

    var loginData = require(path.join(__dirname, "../../lib/login_data.js")).data,
      datasource  = require('../../../node-datasource/lib/ext/datasource').dataSource,
      config      = require(path.join(__dirname, "../../../node-datasource/config.js")),
      creds       = _.extend({}, config.databaseServer, {database: loginData.org});

    before(function (done) {
      var sql = "delete from usrpref where usrpref_name ~ 'test[23]Args';";
      datasource.query(sql, creds, done);
    });

    it("should create a new preference for current user - test2Args", function (done) {
      var sql = "select setUserPreference('test2Args', 'test') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("should create a new preference for 'admin' user - test3Args", function (done) {
      var sql = "select setUserPreference('admin', 'test3Args', 'test') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("should have set both preferences to 'test'", function (done) {
      var sql = "select * from usrpref"                 +
                " where usrpref_name ~ 'test[23]Args'";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows.length, 2, '2 user preferences test[23]Args');
        assert.equal(res.rows.filter(function (e) {
                        return e.usrpref_value === 'test';
                      }).length, 2, "both === 'test'");
        done();
      });
    });

    it("should update existing prefs", function (done) {
      var sql = "select setUserPreference('test2Args', 'newValue') AS a,"    +
                "       setUserPreference('admin', 'test3Args', 'newValue') AS b;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isTrue(res.rows[0].a);
        assert.isTrue(res.rows[0].b);
        done();
      });
    });

    it("should have set both preferences to 'newValue'", function (done) {
      var sql = "select * from usrpref"                 +
                " where usrpref_name ~ 'test[23]Args'";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows.length, 2, '2 user preferences test[23]Args');
        assert.equal(res.rows.filter(function (e) {
                        return e.usrpref_value === 'newValue';
                      }).length, 2, "both === 'newValue'");
        done();
      });
    });

    after(function (done) {
      var sql = "delete from usrpref where usrpref_name ~ 'test[23]Args';";
      datasource.query(sql, creds, done);
    });

  });
}());
