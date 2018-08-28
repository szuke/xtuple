var _      = require("underscore"),
    assert = require('chai').assert;

(function () {
  "use strict";
  describe('getEdition()', function () {

    var loginData  = require("../../lib/login_data.js").data,
        datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
        config     = require("../../../node-datasource/config.js"),
        creds      = _.extend({}, config.databaseServer, {database: loginData.org}),
        edition;

    it("should just work", function (done) {
      var sql = "select getEdition() as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        edition = res.rows[0].result;
        assert.match(edition, /^(Distribution|Enterprise|Manufacturing|PostBooks)$/);
        done();
      });
    });

    it.skip("should match the Application metric", function (done) {
      var sql = "select fetchMetricText('Application') as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].result, edition);
        done();
      });
    });

  });
})();
