(function () {
  "use strict";

  var https = require('https');
  var url = require('url');

  var assert = require("chai").assert;

  var loginData = require('../lib/login_data');
  var database = loginData.data.org;

  describe('The REST discovery document', function () {
    it('should load', function (done) {
      this.timeout(1000 * 100);

      var webaddress = loginData.data.webaddress || 'https://localhost';
      var reqUrl = url.parse(webaddress);
      var delimiter = webaddress.charAt(webaddress.length - 1) === "/" ? "" : "/";

      var requestOptions = {
        hostname: reqUrl.hostname,
        path: delimiter + database + '/discovery/v1alpha1/apis/v1alpha1/rest',
        port: reqUrl.port,
        method: 'GET',
        // TODO: Use valid HTTPS cert?
        rejectUnauthorized: false,
        requestCert: true,
        agent: false
      };

      var request = https.request(requestOptions, function (res) {
        var data = '';

        res.on('data', function (chunk) {
          data = data + chunk;
        });
        res.on('end', function () {
          var isJSON = res.headers['content-type']
            ? res.headers['content-type'].indexOf('application/json') > -1 : false;

          try {
            res.body = isJSON ? JSON.parse(data) : data;
            assert.isString(res.body.discoveryVersion);
            assert.isObject(res.body.schemas.Country);
            assert.isObject(res.body.resources.Sales);
            done();
          } catch (err) {
            console.log('restApiRequest res.body error: ', data);
            done(err);
          }
        });
        res.on('error', function (err) {
          done(err);
        });
      });

      request.end();
    });
  });
}());
