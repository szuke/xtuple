/* jshint laxbreak:true */
var _      = require('underscore'),
    assert = require('chai').assert;

(function () {
  'use strict';
  describe('createInvoice()', function () {

    var loginData  = require('../../lib/login_data.js').data,
        datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
        config     = require('../../../node-datasource/config.js'),
        creds      = _.extend({}, config.databaseServer,
                              { database: loginData.org }),
        coitem      = {},
        cobmisc_id  = -1,
        cobill_id   = -1,
        invchead_id = -1
        ;

    it('needs a coitem to invoice', function(done) {
      var sql = "SELECT *"
              + "  FROM coitem"
              + " WHERE coitem_cohead_id NOT IN (SELECT cobmisc_cohead_id FROM cobmisc)"
              + " LIMIT 1;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        coitem = res.rows[0];
        done();
      });
    });

    it('create a cobmisc to convert', function(done) {
      var sql = "SELECT createBillingHeader(" + coitem.coitem_cohead_id + ") AS result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        cobmisc_id = res.rows[0].result;
        assert(cobmisc_id > 0);
        done();
      });
    });

    it('create a cobill so there is something to invoice', function(done) {
      var sql = "SELECT selectForBilling(" + coitem.coitem_id
              + "," + coitem.coitem_qtyord + ", true) AS result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        cobill_id = res.rows[0].result;
        assert(cobill_id > 0);
        done();
      });
    });

    it('should run without error', function (done) {
      var sql = "SELECT createInvoice(" + cobmisc_id + ") AS result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        invchead_id = res.rows[0].result;
        assert(invchead_id > 0);
        done();
      });
    });

    after(function (done) {
      var sql = "select deleteInvoice(" + invchead_id + ") AS deletei;";
      datasource.query(sql, creds, done);
    });
  });
})();
