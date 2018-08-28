var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";
  var group  = "assessFinanceCharges",
      name   = "detail"
      ;

  describe(group + '-' + name + ' mql', function () {
    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        constants  = {},
        mql
        ;

    it("needs the query", function (done) {
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

    _.each([ constants,         // values chosen from a sample dev db
             _.extend({}, constants, { assessmentDate: '2016-07-01' }),
             _.extend({}, constants, { cust_id:                 102 }),
             _.extend({}, constants, { custtype_id:              19 }),
             _.extend({}, constants, { custtype_pattern:  '[aeiou]' }),
             _.extend({}, constants, { custgrp_id:               25 })
	   ], function (p) {
        it(JSON.stringify(p), function (done) {
          var sql = "do $$"                 +
                    "var params = { params: " + JSON.stringify(p) + "}," +
                    "    mql    = \""         + mql              + "\"," +
                    "    sql    = XT.MetaSQL.parser.parse(mql, params)," +
                    "    rows   = plv8.execute(sql);"                    +
                    "$$ language plv8;";
          datasource.query(sql, adminCred, function (err /*, res*/) {
            assert.isNull(err);
            done();
          });
        });
    });
  });

}());
