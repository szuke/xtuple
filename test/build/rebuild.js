var buildAll = require('../../scripts/lib/build_all'),
  assert = require('chai').assert,
  datasource = require('../../node-datasource/lib/ext/datasource').dataSource,
  path = require('path');

(function () {
  "use strict";
  describe('The database build tool', function () {
    this.timeout(100 * 60 * 1000);

    var loginData = require(path.join(__dirname, "../lib/login_data.js")).data,
      datasource = require('../../../xtuple/node-datasource/lib/ext/datasource').dataSource,
      config = require(path.join(__dirname, "../../node-datasource/config.js")),
      creds = config.databaseServer,
      databaseName = loginData.org;

    it('should rebuild without error on a already built database', function (done) {
      buildAll.build({
        database: databaseName,
        wipeViews: true
      }, function (err, res) {
        assert.isNull(err);
        done();
      });
    });
  });
}());
