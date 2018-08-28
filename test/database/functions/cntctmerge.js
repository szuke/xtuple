var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('cntctMerge()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        src, tgt
        ;

    it("should fail with null source", function (done) {
      var sql = "select cntctMerge(NULL, 0, false) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNotNull(err);
        assert.isUndefined(res); //dblib.assertErrorCode(err, res, 'cntctmrge', -1);
        done();
      });
    });

    it("should fail with null target", function (done) {
      var sql = "select cntctMerge(0, NULL, false) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNotNull(err);
        assert.isUndefined(res); //dblib.assertErrorCode(err, res, 'cntctmrge', -1);
        done();
      });
    });

    it("should fail with null purge flag", function (done) {
      var sql = "select cntctMerge(0, 0, NULL) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNotNull(err);
        assert.isUndefined(res); //dblib.assertErrorCode(err, res, 'cntctmrge', -1);
        done();
      });
    });

    it("needs two contacts to play with", function (done) {
      var sql = "insert into cntct ("                                   +
                "  cntct_crmacct_id, cntct_honorific,"                  +
                "  cntct_addr_id,"                                      +
                "  cntct_first_name, cntct_middle, cntct_last_name,"    +
                "  cntct_initials, cntct_phone, cntct_phone2,"          +
                "  cntct_fax, cntct_email, cntct_webaddr,"              +
                "  cntct_notes, cntct_title, cntct_number"              +
                ") select "                                             +
                "  crmacct_id, crmacct_number,"                         +
                " (select addr_id from addr order by random() limit 1),"+
                "  crmacct_number, crmacct_number, crmacct_number,"     +
                "  crmacct_number, crmacct_number, crmacct_number,"     +
                "  crmacct_number, crmacct_number, crmacct_number,"     +
                "  crmacct_number, crmacct_number, crmacct_number"      +
                "    from crmacct"                                      +
                "   where crmacct_active"                               +
                "     and not exists(select 1 from cntct"               +
                "                   where cntct_number=crmacct_number)" +
                " limit 2 returning *;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 2);
        src = res.rows[0];
        tgt = res.rows[1];
        assert.notEqual(src.cntct_id,         tgt.cntct_id);
        assert.notEqual(src.cntct_crmacct_id, tgt.cntct_crmacct_id);
        done();
      });
    });

    it("needs an f-key that'll be updated", function (done) {
      var sql = "update crmacct set crmacct_cntct_id_1 = $1"      +
                " where crmacct_id = $2 returning crmacct_id;",
          cred = _.extend({}, adminCred,
                          { parameters: [ src.cntct_id, src.cntct_crmacct_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("needs to know which fields come from src", function (done) {
      var sql = "insert into cntctsel ("                                 +
                "  cntctsel_cntct_id,       cntctsel_target,"            +
                "  cntctsel_mrg_crmacct_id, cntctsel_mrg_honorific,"     +
                "  cntctsel_mrg_addr_id,"                                +
                "  cntctsel_mrg_first_name, cntctsel_mrg_middle,"        +
                "  cntctsel_mrg_last_name,  cntctsel_mrg_initials,"      +
                "  cntctsel_mrg_phone,      cntctsel_mrg_phone2,"        +
                "  cntctsel_mrg_fax,        cntctsel_mrg_email,"         +
                "  cntctsel_mrg_webaddr,    cntctsel_mrg_notes,"         +
                "  cntctsel_mrg_title"                                   +
                ") values ("    +
                "  $1,  false," +
                "  true, true,  true, true," + // all these 'true's
                "  true, true,  true, true," + // mean all of the fields
                "  true, true,  true, true,  true, true"  +
                ") returning *;",
          cred = _.extend({}, adminCred, { parameters: [ src.cntct_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it.skip("need a table where 'contact is one of multiple foreign key columns'");
    it.skip("should fail with pPurge set to false");
    it.skip("should work with pPurge set to true");
    it.skip("don't need that table anymore");

    it("should merge two contacts", function (done) {
      var sql  = "select cntctmerge($1, $2, false) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ src.cntct_id, tgt.cntct_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("should have created mrghist records", function (done) {
      var sql = "select count(*) as result from mrghist"        +
                " where mrghist_cntct_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ src.cntct_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].result, ">=", 1); // crmacct + trigger stuff
        done();
      });
    });

    it("should have created a cntctmrgd record", function (done) {
      var sql = "select * from cntctmrgd where cntctmrgd_cntct_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ src.cntct_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isFalse(res.rows[0].cntctmrgd_error);
        done();
      });
    });

    it("should have updated the target", function (done) {
      var sql = "select * from cntct where cntct_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ tgt.cntct_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].cntct_number, tgt.cntct_number);
        _.each(["cntct_crmacct_id", "cntct_addr_id",
                "cntct_honorific", "cntct_first_name", "cntct_middle",
                "cntct_last_name", "cntct_initials",   "cntct_phone",
                "cntct_phone2",    "cntct_fax",        "cntct_email",
                "cntct_webaddr",   "cntct_title"],
               function (e) { assert.equal(res.rows[0][e], src[e]); });
        assert.match(res.rows[0].cntct_notes, new RegExp(src.cntct_notes));
        assert.match(res.rows[0].cntct_notes, new RegExp(tgt.cntct_notes));
        done();
      });
    });

    it("should have made the source inactive", function (done) {
      var sql = "select cntct_active from cntct where cntct_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ src.cntct_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isFalse(res.rows[0].cntct_active);
        done();
      });
    });

    it("should have deleted the cntctsel", function (done) {
      var sql = "select exists(select 1 from cntctsel"  +
                "               where cntctsel_cntct_id = $1) as result;",
          cred = _.extend({}, adminCred, { parameters: [ src.cntct_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.isFalse(res.rows[0].result);
        done();
      });
    });

    it.skip("try everything again with pPurge := true");

  });

}());
