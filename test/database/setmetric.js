var _      = require("underscore"),
    assert = require('chai').assert;

(function () {
  "use strict";
  describe('The setMetric function', function () {

    var loginData = require("../lib/login_data.js").data,
      datasource = require('../../../xtuple/node-datasource/lib/ext/datasource')
                          .dataSource,
      config = require("../../node-datasource/config.js"),
      creds = _.extend({}, config.databaseServer, {database: loginData.org});

    it("should verify that there is no staged data", function (done) {
      var sql = "delete from public.metric where metric_name = 'Test999';";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        done();
      });
    });

    it("should add a new metric", function (done) {
      var sql = "select setmetric('Test999', 'Value999') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should verify that the metric was set", function (done) {
      var sql = "select metric_value from public.metric" +
                " where metric_name = 'Test999';";
      datasource.query(sql, creds, function (err, res) {
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].metric_value, "Value999");
        done();
      });
    });

    it("should update the metric", function (done) {
      var sql = "select setmetric('Test999', 'Value888') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should verify that the metric was set", function (done) {
      var sql = "select metric_value from public.metric where metric_name = 'Test999';";
      datasource.query(sql, creds, function (err, res) {
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].metric_value, "Value888");
        done();
      });
    });

    after(function (done) {
      // cleanup
      var sql = "delete from public.metric where metric_name = 'Test999';";
      datasource.query(sql, creds, done);
    });

  });
}());
