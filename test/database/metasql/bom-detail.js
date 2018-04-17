var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";
  var group  = "bom",
      name   = "detail"
      ;

  describe.skip(group + '-' + name + ' mql - unskip after bug 31820 is fixed', function () {
    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        constants  = {always: 'Always', never: 'Never'},
        mql
        ;

    before(function (done) {
      var sql = "select metasql_query from metasql"        +
                " where metasql_group = '" + group + "'"   +
                "   and metasql_name  = '" + name  + "'"   +
                "   and metasql_grade = 0;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        mql = res.rows[0].metasql_query;
        mql = mql.replace(/"/g, "'").replace(/--.*\n/g, "").replace(/\n/g, " ");
        done();
      });
    });

    before(function (done) {
      var sql = "SELECT bomhead_item_id FROM bomhead LIMIT 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        constants.item_id = res.rows[0].bomhead_item_id;
        done();
      });
    });

    // at least one of these styles of output must be defined
    _.each([ 'byIndented', 'bySingleLvl', 'bySummarized' ],
      function (style) {
        _.each([ _.extend({}, constants, {}),
                 _.extend({}, constants, { effectiveDays:    14 }),
                 _.extend({}, constants, { expiredDays:       7 }),
                 _.extend({}, constants, { futureDays:        7 }),
                 _.extend({}, constants, { revision_id:      -1 }),
                 _.extend({}, constants, { custgrp_id:       25 })
        ], function (p) {
          p[style] = true;
          it.skip(JSON.stringify(p), function (done) {
             var sql = "do $$"
                + "var params = { params: " + JSON.stringify(p) + "},"
                + "    mql    = \""         + mql               + "\","
                + "    sql    = XT.MetaSQL.parser.parse(mql, params),"
                + "    rows   = plv8.execute(sql);"
                + "$$ language plv8;";
            datasource.query(sql, adminCred, function (err /*, res*/) {
              assert.isNull(err);
              done();
            });
          });
        });
      });
  });

}());
