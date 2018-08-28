var _       = require("underscore"),
    assert  = require("chai").assert;

(function () {
  "use strict";

  describe('curr_rate triggers test', function () {

    var loginData  = require("../../lib/login_data.js").data,
        datasource = require("../../../node-datasource/lib/ext/datasource").dataSource,
        config     = require("../../../node-datasource/config.js"),
        creds      = _.extend({}, config.databaseServer, {database: loginData.org}),
        insertSql  = "insert into curr_rate ("                          +
                     "curr_id, curr_rate, curr_effective, curr_expires" +
                      ") VALUES ("                                      +
                      "$1, $2, $3, $4"                                  +
                      ") returning *;",
        updateSql  = "update curr_rate set "                    +
                     "  curr_id = $1,        curr_rate = $2,"   +
                      " curr_effective = $3, curr_expires = $4" +
                      " where curr_rate_id = $5"                +
                      " returning *;",
        base_id    = -1,
        curr_rate,
        fxChangeLog,
        newEffective,
        newExpires,
        newId,
        prev_rate,
        today      = new Date(),
        tomorrow   = new Date();

    today.setHours(0, 0, 0, 0);
    tomorrow.setDate(today.getDate() + 1);

    it("needs base curr, non-base curr, and a curr_rate", function (done) {
      var sql = "select basecurrid() AS base_id, *,"                    +
                "  fetchMetricBool('FXChangeLog') AS log"               +
                "  from curr_rate where curr_id != basecurrid()"        +
                " order by curr_id, curr_expires desc limit 2;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 2);
        base_id   = res.rows[0].base_id;
        curr_rate = res.rows[0];
        prev_rate = res.rows[1];
        fxChangeLog = res.rows[0].log;
        newEffective = new Date(curr_rate.curr_expires);
        newExpires   = new Date(curr_rate.curr_expires);
        newEffective.setDate(newExpires.getDate() + 1);
        newExpires.setDate(newExpires.getDate() + 30);
        done();
      });
    });

    it("needs FXChangeLog == 't' to test thoroughly", function (done) {
      var sql = "select setMetric('FXChangeLog', 't') AS result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should fail on insert with reversed dates", function (done) {
      var options = _.extend({}, creds,
                             { parameters: [ curr_rate.curr_id, 1,
                                             tomorrow,          today ] });
      datasource.query(insertSql, options, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /effective.*expiration/i);
        assert.isUndefined(res);
        done();
      });
    });

    it("should fail on update with reversed dates", function (done) {
      var options = _.extend({}, creds,
                             { parameters: [ curr_rate.curr_id, 1,
                                             tomorrow,          today,
                                             curr_rate.curr_rate_id
                                           ] });
      datasource.query(updateSql, options, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /effective.*expiration/i);
        assert.isUndefined(res);
        done();
      });
    });

    it("should fail on insert with overlapping dates", function (done) {
      var options = _.extend({}, creds,
                             { parameters: [ curr_rate.curr_id, 1,
                                             prev_rate.curr_effective,
                                             curr_rate.curr_expires ] });
      datasource.query(insertSql, options, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /overlap/i);
        assert.isUndefined(res);
        done();
      });
    });

    it("should fail on update with overlapping dates", function (done) {
      var options = _.extend({}, creds,
                             { parameters: [ curr_rate.curr_id, 1,
                                             prev_rate.curr_effective,
                                             curr_rate.curr_expires,
                                             curr_rate.curr_rate_id
                                           ] });
      datasource.query(updateSql, options, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /overlap/i);
        assert.isUndefined(res);
        done();
      });
    });

    it("should succeed on insert", function (done) {
      var options = _.extend({}, creds,
                             { parameters: [ curr_rate.curr_id, 2,
                                             newEffective,      newExpires ] });
      datasource.query(insertSql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        newId = res.rows[0].curr_rate_id;
        done();
      });
    });

    it("should succeed on update", function (done) {
      var options = _.extend({}, creds,
                             { parameters: [ curr_rate.curr_id, 3,
                                             newEffective, newExpires, newId
                                           ] });
      datasource.query(updateSql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].curr_rate_id, newId);
        done();
      });
    });

    it("should succeed on delete", function (done) {
      var sql     = "delete from curr_rate where curr_rate_id = $1" +
                    " returning curr_rate_id;",
          options = _.extend({}, creds, { parameters: [ newId ] });
      datasource.query(sql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].curr_rate_id, newId);
        done();
      });
    });

    describe("if fetchMetricBool('FXChangeLog')", function () {
      it.skip("should insert a comment on insert");
      it.skip("should insert a comment on update");
      it.skip("should insert a comment on delete");
    });

    describe("else if not fetchMetricBool('FXChangeLog')", function () {
      it.skip("should not insert a comment on insert");
      it.skip("should not insert a comment on update");
      it.skip("should not insert a comment on delete");
    });

    it("needs to set FXChangeLog back", function (done) {
      if (! fxChangeLog) {
        var sql = "select setMetric('FXChangeLog', 'f') AS result;";
        datasource.query(sql, creds, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          done();
        });
      } else {
        done();
      }
    });

  });
})();

