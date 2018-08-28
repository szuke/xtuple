var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";
  var group  = "bookings",
      name   = "detail",
      target = 'SO'       // charass_target_type
      ;

  describe(group + '-' + name + ' mql', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        constants  = {},
        mql,
        testcase   = []
        ;

    it("needs the query", function (done) {
      var sql = "select metasql_query from metasql"        +
                " where metasql_group = '"  + group + "'"  +
                "   and metasql_name  = '"  + name  + "'"  +
                "   and metasql_grade = 0;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        mql = res.rows[0].metasql_query;
        mql = mql.replace(/"/g, "'").replace(/--.*\n/g, "").replace(/\n/g, " ");
        done();
      });
    });

    it.skip("needs relevant characteristics", function (done) {
      var sql = "select min(char_id) as char_id, char_type"     +
                "  from char"                                   +
                "  join charuse on char_id = charuse_char_id"   +
                " where char_search"                            +
                "   and charuse_target_type = '" + target + "'" +
                " group by char_type;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        _.each(res.rows, function (row) {
          var test = { charClause: [] };
          switch (row.char_type) {
            // TODO: where do we put the VALUE?
            case dblib.CHARTEXT:
              test.char_id_text_list = [ row.char_id ];
              test.charClause.push("charass_alias" + row.char_id +
                                   ".charass_value ~* '[a-z]'");
              break;
            case dblib.CHARLIST:
              /* skip for now - we need to get list options from the db
              test.char_id_list_list = row.char_id;
              test.charClause.push("charass_alias" + row.char_id +
                               ".charass_value ~* '[a-z]'";
              */
              break;
            case dblib.CHARDATE:
              test.char_id_date_list = row.char_id;
              test.charClause.push("charass_alias" + row.char_id +
                                   ".charass_value::date >= '2016-01-01'");
              test.charClause.push("charass_alias" + row.char_id +
                                   ".charass_value::date <= '2016-12-31'");
              break;
            default:
              assert.isFalse("found unknown char_type" + row.char_type);
              break;
          }
          test.charClause = "AND " + test.charClause.join(" AND ");
          testcase.push(test);
        });
        done();
      });
    });

    // TODO: need to add charClause and char_id_{date,list,text}_list
    it.skip("should succeed with various characteristics", function (done) {
      _.each([ constants,
             _.extend({}, constants, { cohead_id:          3196 }),
             _.extend({}, constants, { custgrp:          'true' }),
             _.extend({}, constants, { custgrp_id:           25 }),
             _.extend({}, constants, { custgrp_pattern: '[a-m]' }),
             _.extend({}, constants, { custtype_id:          19 }),
             _.extend({}, constants, { custtype_pattern: 'MAL-' }),
             _.extend({}, constants, { item_id:             309 }),
             _.extend({}, constants, { openOnly:         'true' }),
             _.extend({}, constants, { orderByOrderdate: 'true' }),
             _.extend({}, constants, { orderByScheddate: 'true' }),
             _.extend({}, constants, { poNumber:   'ABCDEFGHIJ' }),
             _.extend({}, constants, { prodcat_id:           30 }),
             _.extend({}, constants, { prodcat_pattern: 'CLASS' }),
             _.extend({}, constants, { salesrep_id:          30 }),
             _.extend({}, constants, { saletype_id:           2 }),
             _.extend({}, constants, { shipto_id:            31 }),
             _.extend({}, constants, { startDate:  '2016-01-01' }),
             _.extend({}, constants, { warehous_id:          35 })
        ], function (p, i) {
          var sql = "do $$"                 +
                    "var params = { params: " + JSON.stringify(p) + "}," +
                    "    mql    = \""         + mql              + "\"," +
                    "    sql    = XT.MetaSQL.parser.parse(mql, params)," +
                    "    rows   = plv8.execute(sql);"                    +
                    "$$ language plv8;";
console.log(i, sql);
          datasource.query(sql, adminCred, function (err /*, res*/) {
            assert.isNull(err);
            if (i >= testcase.length) { done(); }
          });
      });
      //done();
    });

  });

}());
