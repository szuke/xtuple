var _      = require("underscore"),
    assert = require("chai").assert,
    dblib  = require("../dblib");


(function () {
  "use strict";
  var adminCred  = dblib.adminCred,
      datasource = dblib.datasource,
      group      = "orderActivityByProject",
      name       = "detail",
      constants  = {
          assigned:   'Assigned',
          canceled:   'Canceled',
          closed:     'Closed',
          complete:   'Completed',
          confirmed:  'Confirmed',
          converted:  'Converted',
          expired:    'Expired',
          exploded:   'Exploded',
          feedback:   'Feedback',
          inprocess:  'WIP',
          invoices:   'Invoices',
          "new":      'New',
          open:       'Open',
          planning:   'Planning',
          pos:        'Purchase Orders',
          posted:     'Posted',
          prs:        'Purchase Requests',
          quotes:     'Quotes',
          released:   'Released',
          resolved:   'Resolved',
          sos:        'Sales Orders',
          total:      'Total',
          unposted:   'Unposted',
          unreleased: 'Unreleased',
          wos:        'Work Orders'
      },
    hasTE = false,
    mql;

  describe(group + '-' + name + ' mql', function () {
    before(function (done) {
      var sql = "SELECT metasql_query FROM metasql"     +
                " WHERE metasql_group = $1"             +
                "   AND metasql_name  = $2"             +
                "   AND metasql_grade = 0;",
          creds = _.extend({}, adminCred,
                           { parameters: [ group, name ] });
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        mql = res.rows[0].metasql_query;
        mql = mql.replace(/"/g, "'")
                 .replace(/--.*\n/g, "").replace(/\n/g, " ");
        done();
      });
    });

    before(function (done) {
      var sql = "SELECT prj_id FROM prj LIMIT 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        constants.prj_id = res.rows[0].prj_id;
        done();
      });
    });

    before(function (done) {
      var sql = "SELECT EXISTS(SELECT 1 FROM pkghead"
              + "               WHERE pkghead_name = 'te') AS result;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        hasTE = res.rows[0].result;
        done();
      });
    });

    _.each([ constants,
             _.extend({}, constants, { owner_username: 'admin'  }),
             _.extend({}, constants, { owner_username: 'jsmith' }),
             _.extend({}, constants, { showIn: true }),
             _.extend({}, constants, { showPo: true }),
             _.extend({}, constants, { showSo: true }),
             _.extend({}, constants, { showWo: true }),
             _.extend({}, constants, { showCompleted: true })
           ], function (p) {
             it(JSON.stringify(p), function (done) {
               if (hasTE) {
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
               } else
                 done();
             });
    });
  });
}());
