var _       = require('underscore'),
    assert  = require('chai').assert;

(function () {
  'use strict';

  describe('quhead trigger', function () {

    var dblib      = require('../dblib.js'),
        adminCred  = dblib.adminCred,
        datasource = dblib.datasource;

    it.skip('should try adding a quhead', function (done) {
      var sql = "insert into quhead ("                                  +
                ", columns"                                             +
                ") values ("                                            +
                "  values"                                              +
                ") returning quhead_id;";

      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

  });
})();

