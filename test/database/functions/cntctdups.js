var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('cntctDups()', function () {

    var datasource = dblib.datasource,
        adminCred = dblib.generateCreds(),
        ignoreBlanks = [ false, true ],
        indentedDups = [ false, true ]
        ;

    _.each(ignoreBlanks, function (b) {
      _.each(indentedDups, function (d) {
        var cred = _.extend({}, adminCred, { parameters: [ "[aeiou]", b, d ] });
        it("should not error for " + JSON.stringify(cred.parameters), function (done) {
          var sql = "select * from cntctDups($1, true," +
                    "  true, true, true, true, true,"   +
                    "  $2, $3,"                  + // IgnoreBlanks, IndentedDups
                    "  true, true, true, true, true, true, true);";
          datasource.query(sql, cred, function (err, res) {
            assert.isNull(err);
            console.log(JSON.stringify(res));
            assert.operator(res.rowCount, d ? "===" : ">", 0);
            done();
          });
        });
      });
    });

  });

}());
