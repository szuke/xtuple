var _      = require("underscore"),
    assert = require('chai').assert;

(function () {
  "use strict";
  describe('The database', function () {
    this.timeout(10 * 1000);

    var loginData = require("../lib/login_data.js").data,
      datasource = require('../../../xtuple/node-datasource/lib/ext/datasource').dataSource,
      config = require( "../../node-datasource/config.js"),
      creds = config.databaseServer,
      databaseName = loginData.org;

    it('must not have any overridden tables or views', function (done) {
      var sql = "select pub.relname from pg_class pub "                     +
                "  join pg_namespace pubns on pub.relnamespace = pubns.oid" +
                "                         and pubns.nspname = 'public' "    +
                "  join pg_class xt on pub.relname = xt.relname "           +
                "  join pg_namespace xtns on xt.relnamespace = xtns.oid"    +
                "                        and xtns.nspname = 'xt' "          +
                " where pub.relkind NOT IN ('i', 'c'); ";

      creds.database = databaseName;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        // TODO: fix bug 25656 then assert # rows === 0
        _.each(res.rows, function (elem) {
          assert.ok(/potype(_potype_id_seq)?/.test(elem.relname),
                    'only allow multiple potype tables');
        });
        done();
      });
    });

    it('must only override a few whitelisted functions', function (done) {
      var sql = "select pub.proname from pg_proc pub "                      +
                "  join pg_namespace pubns on pub.pronamespace = pubns.oid" +
                "                         and pubns.nspname = 'public' "    +
                "  join pg_proc xt on pub.proname = xt.proname "            +
                "  join pg_namespace xtns on xt.pronamespace = xtns.oid"    +
                "                         and xtns.nspname = 'xt'; ";

      creds.database = databaseName;
      datasource.query(sql, creds, function (err, res) {
        var overriddenFunctions = _.map(res.rows, function (row) {
            return row.proname;
          }),
          whitelist = ["cntctmerge", "cntctrestore", "createuser",
            "mergecrmaccts", "trylock", "undomerge", "uuid_generate_v4"],
          illegalFunctions = _.difference(overriddenFunctions, whitelist);

        assert.isNull(err);
        assert.equal(illegalFunctions.length, 0, JSON.stringify(illegalFunctions));
        done();
      });
    });

  });
}());
