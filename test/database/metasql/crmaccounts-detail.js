var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";
  var group   = 'bomItems',
      name    = 'detail',
      target  = 'CRMACCT'
      ;

  describe(group + '-' + name + ' mql', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        mql,
        testcase   = []
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

    it.skip("should succeed with various characteristics", function (done) {
      _.each(testcase, function (p, i) {
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
