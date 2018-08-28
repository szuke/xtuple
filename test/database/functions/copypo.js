var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('copyPO()', function () {

    var datasource = dblib.datasource,
        adminCred = dblib.generateCreds(),
        samevend = {},
        oldpo
        ;

    it("should find an order to copy", function (done) {
      var sql = "select *,"                                             +
                 "      (select count(*) from poitem"                   +
                 "        where poitem_pohead_id = pohead_id) as lines" +
                "  from pohead limit 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        oldpo = res.rows[0];
        done();
      });
    });

    it("should copy with the same vendor", function (done) {
      var sql = "select copyPO($1, $2, current_date, false) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ oldpo.pohead_id, oldpo.pohead_vend_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        samevend.pohead_id = res.rows[0].result;
        assert.operator(samevend.pohead_id, '>=', 0);
        done();
      });
    });

    it("should have similar data", function (done) {
      var sql  = "select pohead.*,"                                     +
                 "       (select count(*) from poitem"                  +
                 "         where poitem_pohead_id = $1) as lines"       +
                 "  from pohead where pohead_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ samevend.pohead_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, 'one row');
        samevend = res.rows[0];
        assert.notEqual(samevend.pohead_id, 0, 'id');
        assert.notEqual(samevend.pohead_id, oldpo.pohead_id, 'id');
        assert.notEqual(samevend.pohead_number, oldpo.pohead_number, 'number');
        assert.equal(samevend.pohead_vend_id, oldpo.pohead_vend_id, 'vend_id');
        assert.equal(samevend.pohead_vend_cntct_id, oldpo.pohead_vend_cntct_id, 'vend cntct');
        assert.equal(samevend.pohead_type, oldpo.pohead_type, 'type');
        assert.equal(samevend.pohead_shipvia, oldpo.pohead_shipvia, 'shipvia');
        assert.equal(samevend.pohead_freight, oldpo.pohead_freight, 'freight');
        assert.equal(samevend.pohead_dropship, oldpo.pohead_dropship, 'dropship');
        assert.equal(samevend.pohead_fob, oldpo.pohead_fob, 'fob');
        assert.equal(samevend.pohead_agent_username, oldpo.pohead_agent_username, 'agent_username');
        assert.equal(samevend.lines, oldpo.lines, 'line count');
        done();
      });
    });

    it("should /not/ copy with a different vendor", function (done) {
      var sql = "select copyPO($1, vend_id, current_date, false) as result"    +
                "  from vendinfo"                                       +
                " where vend_id != $2 and vend_active limit 1;",
          cred = _.extend({}, adminCred,
                          { parameters: [ oldpo.pohead_id, oldpo.pohead_vend_id ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "copyPO", -2);
        done();
      });
    });

    it("should fail with a non-existent po", function (done) {
      var sql = "select copyPO(-5, $1, current_date, false) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ oldpo.pohead_vend_id ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "copyPO", -1);
        done();
      });
    });

    it("should fail with a non-existent vendor", function (done) {
      var sql = "select copyPO($1, -5, current_date, false) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ oldpo.pohead_id ] });
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, "copyPO"); // unsure what err to expect
        done();
      });
    });

  });

}());
