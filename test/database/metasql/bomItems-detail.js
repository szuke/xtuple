var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";
  var group   = 'bomItems',
      name    = 'detail'
      ;

  describe(group + '-' + name + ' mql', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        constants  = {
                      always:           'Always',
                      assortment:       'Asstmt',
                      breeder:          'Breeder',
                      byProduct:        'ByP',
                      coProduct:        'CoP',
                      costing:          'Cost',
                      error:            'ERR',
                      job:              'Job',
                      kit:              'Kit',
                      manufactured:     'Man',
                      mixed:            'Mix',
                      never:            'Never',
                      outside:          'Out',
                      phantom:          'Phantom',
                      planning:         'Plan',
                      pull:             'Pull',
                      purchased:        'Purch',
                      push:             'Push',
                      reference:        'Ref',
                      tooling:          'Tool',
        },
        hasXtmfg = false,
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

    it("needs to know if xtmfg is available", function (done) {
      var sql = "select packageIsEnabled('xtmfg') as result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        hasXtmfg = res.rows[0].result;
        done();
      });
    });

    _.each([ constants,
             _.extend({}, constants, { booitem_id:  14 }),
             _.extend({}, constants, { item_id:     309, revision_id: -1 }),
             _.extend({}, constants, { showExpired: 'true'}),
             _.extend({}, constants, { showFuture:  'true'}) 
    ], function (p) {
        it(JSON.stringify(p), function (done) {
          var sql = "do $$"                 +
                    "var params = { params: " + JSON.stringify(p) + "}," +
                    "    mql    = \""         + mql              + "\"," +
                    "    sql    = XT.MetaSQL.parser.parse(mql, params)," +
                    "    rows   = plv8.execute(sql);"                    +
                    "$$ language plv8;";
          datasource.query(sql, adminCred, function (err /*, res*/) {
            if (! hasXtmfg && p.booitem_id) {
              assert.isNotNull(err);
            } else {
              assert.isNull(err);
            }
            done();
          });
        });
    });
  });

}());
