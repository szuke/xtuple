(function () {
  "use strict";

  var zombie = require("zombie"),
    assert = require("chai").assert;

  // Allow self signed cert for our test.
  // @See: https://github.com/assaf/zombie/issues/605
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

  var loginData = require('../lib/login_data'),
    database = loginData.data.org,
    host = loginData.data.webaddress || "https://localhost",
    delimiter = host.charAt(host.length - 1) === "/" ? "" : "/",
    discoveryPath = host + delimiter + database +
                    "/discovery/v1alpha1/apis/v1alpha1/rest",
    maxWait = 100000;

  describe('The REST discovery document', function () {
    it('should load', function (done) {
      this.timeout(maxWait);
      zombie.visit(discoveryPath, {maxWait: maxWait}, function (e, browser) {
        var doc;

        assert.ok(browser.success);
        doc = JSON.parse(browser.text("body"));
        assert.isString(doc.discoveryVersion);
        assert.isObject(doc.schemas.Country);
        assert.isObject(doc.resources.Sales);
        done();
      });
    });
  });
}());
