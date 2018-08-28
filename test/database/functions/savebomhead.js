var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('saveBomHead()', function () {
    var datasource = dblib.datasource,
        adminCred = dblib.generateCreds(),
        hasRev    = false,
        bominfo, current, item, metric
        ;

    it("needs to know if rev table is available", function (done) {
      var sql = "select exists(select 1 from pg_class"  +
                "       where relname = 'rev' and relkind = 'r') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        hasRev = res.rows[0].result;
        done();
      });
    });

    it("needs to save initial RevControl setting", function (done) {
      var sql = "select fetchMetricBool('RevControl') as RevControl;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        metric = res.rows[0];
        done();
      });
    });

    it("needs testing with RevControl turned off", function (done) {
      var sql = "select setMetric('RevControl', 'f') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("needs to know how many bomheads exist", function (done) {
      var sql = "select count(*) as count, max(bomhead_id) as max from bomhead;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        bominfo = res.rows[0];
        done();
      });
    });

    it("needs two items without bomheads and one with", function (done) {
      var sql = "select min(item_id) as item_id, false as hasbom from item"     +
                " where item_id not in (select bomhead_item_id from bomhead)"   +
                " union "                                                       +
                "select max(item_id) as item_id, false as hasbom from item"     +
                " where item_id not in (select bomhead_item_id from bomhead)"   +
                " union "                                                       +
                "select min(bomhead_item_id), true from bomhead"                +
                " order by hasbom, item_id;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 3);
        item = res.rows;
        assert.isFalse(item[0].hasbom, "1st without bom");
        assert.isFalse(item[1].hasbom, "2nd without bom");
        assert.isTrue(item[2].hasbom,  "3rd with bom");
        assert.notEqual(item[0].item_id, item[1].item_id);
        done();
      });
    });

    it("should run when no bomhead exists, no revcontrol", function (done) {
      var sql  = "select saveBomHead($1, NULL, NULL, 'testinsert', 5, 5)" +
                 "    as result;",
          cred = _.extend({}, adminCred, { parameters: [ item[0].item_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.operator(res.rows[0].result, ">", 0);
        item[0].bomhead_id = res.rows[0].result;
        done();
      });
    });

    it("should have inserted a new bomhead, no revcontrol", function (done) {
      var sql  = "select * from bomhead"  +
                 " where bomhead_id = $1 and bomhead_item_id = $2;",
          cred = _.extend({}, adminCred,
                        { parameters: [ item[0].bomhead_id, item[0].item_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].bomhead_docnum, 'testinsert');
        assert.operator(res.rows[0].bomhead_id, ">", bominfo.max);
        done();
      });
    });

    it("should have increased the number of bomheads, no revcontrol",
        function (done) {
      var sql = "select count(*) as count, max(bomhead_id) as max from bomhead;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].count, bominfo.count + 1);
        bominfo = res.rows[0];
        done();
      });
    });

    it("should run when a bomhead exists, no revcontrol", function (done) {
      var sql  = "select saveBomHead($1, NULL, NULL, 'testupdate', 5, 5)" +
                 "    as result;",
          cred = _.extend({}, adminCred, { parameters: [ item[0].item_id ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, item[0].bomhead_id);
        done();
      });
    });

    it("should not have increased the number of bomheads, no revcontrol",
        function (done) {
      var sql = "select count(*) as count, max(bomhead_id) as max from bomhead;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].count, bominfo.count);
        bominfo = res.rows[0];
        done();
      });
    });

    it("needs testing with RevControl turned on", function (done) {
      var sql = "select setMetric('RevControl', 't') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should run when no bomhead exists, w/ revcontrol", function (done) {
      var sql  = "select saveBomHead($1, NULL, NULL, 'testinsert', 5, 5)" +
                 "    as result;",
          cred = _.extend({}, adminCred, { parameters: [ item[1].item_id ] });
      if (hasRev) {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].result, ">", 0);
          item[1].bomhead_id = res.rows[0].result;
          done();
        });
      } else {
        done();
      }
    });

    it("should have inserted a new bomhead, w/ revcontrol", function (done) {
      var sql  = "select * from bomhead"  +
                 " where bomhead_id = $1 and bomhead_item_id = $2;",
          cred = _.extend({}, adminCred,
                        { parameters: [ item[1].bomhead_id, item[1].item_id ] });
      if (hasRev) {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].bomhead_docnum, 'testinsert');
          assert.operator(res.rows[0].bomhead_id, ">", bominfo.max);
          done();
        });
      } else {
        done();
      }
    });

    it("should have increased the number of bomheads, w/ revcontrol",
        function (done) {
      var sql = "select count(*) as count, max(bomhead_id) as max from bomhead;";
      if (hasRev) {
        datasource.query(sql, adminCred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].count, bominfo.count + 1);
          bominfo = res.rows[0];
          done();
        });
      } else {
        done();
      }
    });

    it("should run when a bomhead exists, w/ revcontrol", function (done) {
      var sql  = "select saveBomHead($1, NULL, NULL, 'testupdate', 5, 5)" +
                 "    as result;",
          cred = _.extend({}, adminCred, { parameters: [ item[1].item_id ] });
      if (hasRev) {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].result, item[1].bomhead_id);
          done();
        });
      } else {
        done();
      }
    });

    it("should not have increased the number of bomheads, w/ revcontrol",
        function (done) {
      var sql = "select count(*) as count, max(bomhead_id) as max from bomhead;";
      if (hasRev) {
        datasource.query(sql, adminCred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].count, bominfo.count);
          done();
        });
      } else {
        done();
      }
    });

    it("should run when bomhead exists, w/ rev", function (done) {
      var sql  = "select saveBomHead($1, '1.0', NULL, 'testaddrev', 5, 5)" +
                 "    as result;",
          cred = _.extend({}, adminCred, { parameters: [ item[1].item_id ] });
      if (hasRev) {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].result, ">", 0);
          item[1].bomhead_id = res.rows[0].result;
          done();
        });
      } else {
        done();
      }
    });

    it("should not have inserted a new bomhead, w/ rev", function (done) {
      var sql  = "select * from bomhead"  +
                 " where bomhead_id = $1 and bomhead_item_id = $2;",
          cred = _.extend({}, adminCred,
                        { parameters: [ item[1].bomhead_id, item[1].item_id ] });
      if (hasRev) {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].bomhead_docnum, 'testaddrev');
          assert.equal(res.rows[0].bomhead_revision, '1.0');
          assert.equal(res.rows[0].bomhead_id, bominfo.max);
          current = res.rows[0];
          done();
        });
      } else {
        done();
      }
    });

    it("should not have increased the number of bomheads, w/ rev",
        function (done) {
      var sql = "select count(*) as count, max(bomhead_id) as max from bomhead;";
      if (hasRev) {
        datasource.query(sql, adminCred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].count, bominfo.count);
          bominfo = res.rows[0];
          done();
        });
      } else {
        done();
      }
    });

    it("should have created a rev, w/ rev", function (done) {
      var sql  = "select * from rev"    +
                 " where rev_target_type = 'BOM' and rev_target_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ item[1].item_id ] });
      if (hasRev) {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].rev_id,        current.bomhead_rev_id);
          assert.equal(res.rows[0].rev_number,    current.bomhead_revision);
          assert.equal(res.rows[0].rev_target_id, current.bomhead_item_id);
          bominfo = res.rows[0];
          done();
        });
      } else {
        done();
      }
    });

    it("should run when a bomhead exists, w/ different rev", function (done) {
      var sql  = "select saveBomHead($1, '2.0', NULL, 'testupdrev', 5, 5)" +
                 "    as result;",
          cred = _.extend({}, adminCred, { parameters: [ item[1].item_id ] });
      if (hasRev) {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.notEqual(res.rows[0].result, item[1].bomhead_id);
          item[1].bomhead_id = res.rows[0].result;
          done();
        });
      } else {
        done();
      }
    });

    it("should have inserted a new bomhead, w/ different rev",
        function (done) {
      var sql  = "select * from bomhead"  +
                 " where bomhead_id = $1 and bomhead_item_id = $2;",
          cred = _.extend({}, adminCred,
                        { parameters: [ item[1].bomhead_id, item[1].item_id ] });
      if (hasRev) {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].bomhead_docnum, 'testupdrev');
          assert.equal(res.rows[0].bomhead_revision, '2.0');
          current = res.rows[0];
          done();
        });
      } else {
        done();
      }
    });

    it("should have created a rev, w/ different rev", function (done) {
      var sql  = "select * from rev"    +
                 " where rev_target_type = 'BOM' and rev_target_id = $1;",
          cred = _.extend({}, adminCred, { parameters: [ item[1].item_id ] });
      if (hasRev) {
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 2);
          /*
          assert.notEqual(res.rows[0].rev_id,     current.bomhead_rev_id);
          assert.notEqual(res.rows[0].rev_number, current.bomhead_revision);
          assert.equal(res.rows[0].rev_target_id, current.bomhead_item_id);
          assert.equal(res.rows[0].rev_number,    '2.0');
          */
          done();
        });
      } else {
        done();
      }
    });

    it("needs to restore RevControl", function (done) {
      var sql = "select setMetric('RevControl', $1) as result;",
          cred = _.extend({}, adminCred,
                          { parameters: [ metric.RevControl ? 't' : 'f' ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

  });

}());
