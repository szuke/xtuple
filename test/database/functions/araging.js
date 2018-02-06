var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('araging()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        nonbaseCust = false,
        agingData,
        altdate
        ;

    it("needs to know a date in the aropen duedate range", function (done) {
      var sql = "SELECT MAX(aropen_duedate) - interval '90 days' AS aropen_duedate"
              + "  FROM aropen"
              + " WHERE aropen_duedate < CURRENT_DATE";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        altdate = res.rows[0].aropen_duedate;
        done();
      });
    });

    it("needs to know if any customers use non-base currencies", function (done) {
      var sql = "SELECT EXISTS(SELECT 1 FROM custinfo" +
                "               WHERE cust_curr_id != basecurrid()) AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        nonbaseCust = res.rows[0].result;
        done();
      });
    });

    it("should return nothing for old dates", function (done) {
      var sql = "SELECT * from araging('1970-01-01'::DATE, false);";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 0);
        done();
      });
    });

    it("should handle 2 args", function (done) {
      var sql = "SELECT * from araging(CURRENT_DATE, false);";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">", 0);
        _.each(res.rows, function (row) {
          assert.equal(row.araging_cur_val   + row.araging_thirty_val +
                       row.araging_sixty_val + row.araging_ninety_val +
                       row.araging_plus_val, row.araging_total_val);
        });
        agingData = res.rows;
        done();
      });
    });

    it("should return same result for 3 args as for 2 when using base curr", function (done) {
      var sql = "SELECT * from araging(CURRENT_DATE, false, true);";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, agingData.length);
        _.each(res.rows, function (row, i) {
          _.each(row, function (field, name) {
            if (name.indexOf('date') >= 0)
              return;
            assert.equal(field, agingData[i][name]);
          });
          assert.equal(row.araging_cur_val   + row.araging_thirty_val +
                       row.araging_sixty_val + row.araging_ninety_val +
                       row.araging_plus_val, row.araging_total_val);
        });
        done();
      });
    });

    it("should return diff results when using different doc date", function (done) {
      var sql = "SELECT * from araging(CURRENT_DATE, true);";
      datasource.query(sql, adminCred, function (err, res) {
        var bool_and_val = true;
        var bool_and_date = true;
        assert.isNull(err);
        assert.equal(res.rowCount, agingData.length);
        _.each(res.rows, function (row, i) {
          bool_and_date = bool_and_date && (row.aropen_docdate == row.aropen_distdate);
          _.each(row, function (field, name) {
            if (name.indexOf('_val') >=0)
              bool_and_val = bool_and_val && (field == agingData[i][name]);
          });
          assert.equal(row.araging_cur_val   + row.araging_thirty_val +
                       row.araging_sixty_val + row.araging_ninety_val +
                       row.araging_plus_val, row.araging_total_val);
        });
        if (bool_and_date)
          assert.isTrue(bool_and_val);
        else
          assert.isFalse(bool_and_val);
        done();
      });
    });

    it("should return diff results when converting to cust currency", function (done) {
      var sql = "SELECT * from araging(CURRENT_DATE, false, false);";
      datasource.query(sql, adminCred, function (err, res) {
        var bool_and = true;
        assert.isNull(err);
        assert.equal(res.rowCount, agingData.length);
        _.each(res.rows, function (row, i) {
          _.each(row, function (field, name) {
            if (name.indexOf('_val') >=0)
              bool_and = bool_and && (field == agingData[i][name]);
          });
          assert.equal(row.araging_cur_val   + row.araging_thirty_val +
                       row.araging_sixty_val + row.araging_ninety_val +
                       row.araging_plus_val, row.araging_total_val);
        });
        if (nonbaseCust)
          assert.isFalse(bool_and);
        else
          assert.isTrue(bool_and);
        done();
      });
    });

    it("should return diff results when using a different aging date", function (done) {
      var sql = "SELECT * FROM araging($1, false);",
          cred = _.extend({}, adminCred, { parameters: [ altdate ] });
      datasource.query(sql, cred, function (err, res) {
        var bool_and_val  = true;
        assert.isNull(err);
        if (res.rowCount == agingData.length)
        {
          _.each(res.rows, function (row, i) {
            _.each(row, function (field, name) {
              if (name.indexOf('date') >=0)
                return;
              bool_and_val = bool_and_val && (field == agingData[i][name]);
            });
          });
          assert.isFalse(bool_and_val);
        }
        _.each(res.rows, function (row, i) {
          assert.equal(row.araging_cur_val   + row.araging_thirty_val +
                       row.araging_sixty_val + row.araging_ninety_val +
                       row.araging_plus_val, row.araging_total_val);
        });
        done();
      });
    });

  });

}());
