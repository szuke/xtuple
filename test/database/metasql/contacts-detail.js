var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";
  var group  = 'contacts',
      name   = 'detail',
      target = 'CNTCT'
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

    // TODO: need to add charClause and char_id_{date,list,text}_list
    _.each([ constants,
             _.extend({}, constants, { idOnly:                        'true' }),
             _.extend({}, constants, { hasContext:                    'true' }),
             _.extend({}, constants, { owner_username:               'admin' }),
             _.extend({}, constants, { owner_usr_pattern:             'tes*' }),
             _.extend({}, constants, { activeOnly:                    'true' }),
             _.extend({}, constants, { search_pattern:                  'qu' }),
             _.extend({}, constants, { cntct_id:                          21 }),
             _.extend({}, constants, { crmacct_id:                        16 }),
             _.extend({}, constants, { cntct_name_pattern:             'Fra' }),
             _.extend({}, constants, { cntct_phone_pattern:             '00' }),
             _.extend({}, constants, { cntct_email_pattern:            'edu' }),
             _.extend({}, constants, { addr_street_pattern:         '[0-9]-' }),
             _.extend({}, constants, { addr_city_pattern:              'San' }),
             _.extend({}, constants, { addr_state_pattern:          'V[aei]' }),
             _.extend({}, constants, { addr_postalcode_pattern: '[A-Z][0-9]' }),
             _.extend({}, constants, { addr_country_pattern:         'U[SA]' }),
             _.extend({}, constants, { id:                                15 }),
             _.extend({}, constants, { addr_id:                           47 }),
    ], function (p) {
        it.skip(JSON.stringify(p), function (done) {
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
