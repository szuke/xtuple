var _      = require("underscore"),
    assert = require('chai').assert;

(function () {
  "use strict";
  describe('saveAddr()', function () {

    var loginData = require("../../lib/login_data.js").data,
      datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
      config = require("../../../node-datasource/config.js"),
      creds = _.extend({}, config.databaseServer, {database: loginData.org}),
      uniqueIds = [],
      existingAddr,
      existingAddrCount = 0,
      tmpAddrId;

    function buildSaveAddr(addr) {
      var sql;
      sql = "select saveAddr("  +
            (addr.addr_id      ?       addr.addr_id            : "NULL") + "," +
            (addr.addr_number  ? "'" + addr.addr_number  + "'" : "NULL") + "," +
            (addr.addr_line1   ? "'" + addr.addr_line1   + "'" : "NULL") + "," +
            (addr.addr_line2   ? "'" + addr.addr_line2   + "'" : "NULL") + "," +
            (addr.addr_line3   ? "'" + addr.addr_line3   + "'" : "NULL") + "," +
            (addr.addr_city    ? "'" + addr.addr_city    + "'" : "NULL") + "," +
            (addr.addr_state   ? "'" + addr.addr_state   + "'" : "NULL") + "," +
            (addr.addr_postalcode ? "'" + addr.addr_postalcode + "'" : "NULL") + "," +
            (addr.addr_country ? "'" + addr.addr_country + "'" : "NULL") + "," +
            (addr.addr_active  ? "true"                        :"false") + "," +
            (addr.addr_notes   ? "'" + addr.addr_notes   + "'" : "NULL") + "," +
            (addr.flag         ? "'" + addr.flag         + "'" : "NULL")       +
            ") as result;";
      return sql;
    }

    it("needs a list of unique addresses", function (done) {
      var sql = "select addr_id, UPPER(formatAddr(addr_id)) AS f from addr order by 2;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        for (var i = 0; i < res.rows.length - 1; i++) {
          if (res.rows[i].f === res.rows[i+1].f) {
            i++;
          } else {
            uniqueIds.push(res.rows[i].addr_id);
          }
        }
        done();
      });
    });

    it("needs address count to test against", function (done) {
      var sql = "select count(*) AS rows from addr;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount >= 1);
        existingAddrCount = res.rows[0].rows;
        assert(existingAddrCount >= 1);
        done();
      });
    });

    it("needs sample addresses to test against", function (done) {
      var sql = "select * from addr"                                    +
                " where addrUseCount(addr_id) > 1"                      +
                "   and addr_id in (" + uniqueIds.join(",") + ")"       +
                " limit 2;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount > 1);
        existingAddr = res.rows;
        done();
      });
    });

    it("should fail when flag is invalid", function (done) {
      var addr = { addr_id: -1, flag: 'Garbage' },
          sql = buildSaveAddr(addr);
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /invalid flag/i);
        assert.isUndefined(res);
        done();
      });
    });

    it("should return NULL when given NULL inputs", function (done) {
      var addr = { addr_id: -1, flag: 'CHANGEONE' },
          sql = buildSaveAddr(addr);
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isNull(res.rows[0].result);
        done();
      });
    });

    it("should return the addr_id when nothing changes", function (done) {
      var addr = _.extend({}, existingAddr[0]);
      addr.flag = 'CHANGEALL';
      var sql = buildSaveAddr(addr);
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].result, existingAddr[0].addr_id);
        done();
      });
    });

    it("should return the addr_id when only the notes change", function (done) {
      var addr = _.extend({}, existingAddr[0]);
      addr.addr_id    = -1;
      addr.addr_notes = "additional characters";
      var sql = buildSaveAddr(addr);
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].result, existingAddr[0].addr_id);
        done();
      });
    });

    it("should have updated the notes when only the notes change", function (done) {
      var addr = _.extend({}, existingAddr[0]),
          sql  = "select addr_notes from addr where addr_id = $1;",
          cred = _.extend({}, creds, { parameters: [ addr.addr_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.include(res.rows[0].addr_notes, "additional characters");
        assert.include(res.rows[0].addr_notes, addr.addr_notes);
        done();
      });
    });

    it("should give a new addr_id for unknown addr_id and new data", function (done) {
      var addr = { addr_id:    -1,
                   addr_line1: Date.now() + " York St.",
                   addr_city:  'Norfolk',
                   addr_state: 'VA',
                   addr_postalCode: '23510',
                   addr_country:    'USA' },
          sql  = buildSaveAddr(addr);

      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        tmpAddrId = res.rows[0].result;
        assert(tmpAddrId > existingAddrCount); // minimal criterion
        done();
      });
    });

    it("should allow mods with CHECK flag if the address is unused", function (done) {
      var addr = { addr_id:    tmpAddrId,
                   addr_line1: Date.now() % 1000 + " York St.",
                   addr_city:  'Norfolk',
                   addr_state: 'VA',
                   addr_postalCode: '23510',
                   addr_country:    'USA',
                   flag:            'CHECK' },
          sql  = buildSaveAddr(addr);

      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].result, tmpAddrId);
        done();
      });
    });

    it("should return a warning with CHECK flag if the address is used", function (done) {
      var addr = _.extend({}, existingAddr[1]);
      addr.addr_line1 = Date.now() % 1000 + " York St.";
      addr.flag       = 'CHECK';
      var sql  = buildSaveAddr(addr);

      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].result, -2);
        done();
      });
    });

    it("should return OK with CHANGEALL flag if the address is used", function (done) {
      var addr = _.extend({}, existingAddr[1]);
      addr.addr_line1 = Date.now() % 1000 + " York St.";
      addr.flag       = 'CHANGEALL';
      var sql  = buildSaveAddr(addr);

      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rows[0].result, addr.addr_id);
        done();
      });
    });

    it("should have updated the address when CHANGEALL was used", function (done) {
      var addr = _.extend({}, existingAddr[1]),
          sql = "select * from addr where addr_id = " + addr.addr_id + ";";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.notEqual(res.rows[0].addr_line1, addr.addr_line1);
        done();
      });
    });

    it("should create a new record if CHANGEONE is passed", function (done) {
      var addr = _.extend({}, existingAddr[1]);
      addr.addr_line1 = Date.now() % 1000 + " York St.";
      addr.flag       = 'CHANGEONE';
      var sql  = buildSaveAddr(addr);

      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.notEqual(res.rows[0].result, addr.addr_id);
        assert(res.rows[0].result > existingAddrCount);
        done();
      });
    });

  });
}());
