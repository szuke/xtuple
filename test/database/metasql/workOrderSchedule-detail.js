var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";
  var group  = "workOrderSchedule",
      name   = "detail"
      ;

  describe(group + '-' + name + ' mql', function () {
    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        constants  = { open:      'Open', exploded: 'Exploded', released: 'Released',
                       inprocess: 'WIP',  closed:   'Closed',
                       wo:        'Work Order',  planord: 'Planned Order', mps: 'MPS',
                       so:        'Sales Order', quote:   'Quote',
                       overdue:   'Late', ontime: 'On Time'
                     },
          mql
          ;

    before(function (done) {
      var sql = "select metasql_query from metasql" +
                " where metasql_group = $1"         +
                "   and metasql_name  = $2"         +
                "   and metasql_grade = 0;",
          cred = _.extend({}, adminCred, { parameters: [ group, name ] });

      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        mql = res.rows[0].metasql_query;
        mql = mql.replace(/"/g, "'").replace(/--.*\n/g, "").replace(/\n/g, " ");
        done();
      });
    });

    _.each([ constants,
             _.extend({}, constants, { isReport:           true }),
             _.extend({}, constants, { woSoStatus:         true }),
             _.extend({}, constants, { woSoStatusMismatch: true }),
             _.extend({}, constants, { showOnlyRI:         true }),
             _.extend({}, constants, { showOnlyTopLevel:   true }),
             _.extend({}, constants, { sortByStartDate:    true }),
             _.extend({}, constants, { sortByDueDate:      true }),
             _.extend({}, constants, { sortByItemNumber:   true }),
             _.extend({}, constants, { classcode_id:      1 }),
             _.extend({}, constants, { classcode_pattern: 'A' }),
             _.extend({}, constants, { endDate:           '2018-12-31' }),
             _.extend({}, constants, { item_id:           2 }),
             _.extend({}, constants, { itemgrp_id:        3 }),
             _.extend({}, constants, { itemgrp_pattern:   'B' }),
             _.extend({}, constants, { plancode_id:       4 }),
             _.extend({}, constants, { plancode_pattern:  'C' }),
             _.extend({}, constants, { prj_id:            5 }),
             _.extend({}, constants, { search_pattern:    'D' }),
             _.extend({}, constants, { startDate:         '2018-01-01' }),
//           _.extend({}, constants, { status_list:       [ 'E', 'O' ] }),
             _.extend({}, constants, { warehous_id:       6 }),
             _.extend({}, constants, { wo_id:             7 }),
//           _.extend({}, constants, { wrkcnt_id:         8 }),
//           _.extend({}, constants, { wrkcnt_pattern:    'F' }),

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
