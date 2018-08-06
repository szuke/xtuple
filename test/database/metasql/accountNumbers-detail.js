var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";
  var group  = "accountNumbers",
      name   = "detail"
      ;

  describe(group + '-' + name + ' mql', function () {
    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        constants  = { asset:  'Ast', expense: 'Exp', liability: 'Lia',
                       equity: 'Eqy', revenue: 'Rev' },
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

    _.each([ constants,
             _.extend({}, constants, { showExternal: true }),
             _.extend({}, constants, { showInactive: true }),
             _.extend({}, constants, { accnt_type:   'R'  }),
             _.extend({}, constants, { subaccnt_type: 15  })
    ], function (p) {
        it(JSON.stringify(p), function (done) {
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

}());
