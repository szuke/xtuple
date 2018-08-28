var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('importBankRecCleared()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        metricList = [ { type: 'Value', name: 'ImportBankRecId'        },
                       { type: 'Value', name: 'ImportBankRecDebitAdj'  },
                       { type: 'Value', name: 'ImportBankRecCreditAdj' }
                     ],
        bankrec, bankrecimport, metric
        ;

    it("needs to save some metrics", function (done) {
     var sql = dblib.getMetricsQry(metricList);
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        metric = res.rows[0];
        done();
      });
    });

    it("needs an open bankrec to test with", function (done) {
      var sql  = "select * from bankrec"                                       +
                 "  join bankaccnt on bankrec_bankaccnt_id = bankaccnt_id"     +
                 "  join bankadj   on bankadj_bankaccnt_id = bankaccnt_id"     +
                 "  join bankadjtype on bankadj_bankadjtype_id=bankadjtype_id" +
                 " where not bankrec_posted limit 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        if (res.rowCount === 1) {
          bankrec = res.rows[0];
          done();
        } else {
          sql  = "insert into bankrec (bankrec_bankaccnt_id,"    +
                 "  bankrec_opendate, bankrec_openbal"           +
                 ") select bankrec_bankaccnt_id,"                +
                 "         bankrec_enddate + 1, bankrec_endbal"  +
                 "    from bankrec"                              +
                 "    join bankaccnt on bankrec_bankaccnt_id = bankaccnt_id"   +
                 "    join bankadj   on bankadj_bankaccnt_id = bankaccnt_id"   +
                 "    join bankadjtype on bankadj_bankadjtype_id=bankadjtype_id"+
                 "   where bankrec_posted"                       +
                 "   order by bankrec_enddate desc"              +
                 "   limit 1 returning *;";
          datasource.query(sql, adminCred, function (err, res) {
            assert.isNull(err);
            if (res.rowCount === 1) {
              bankrec = res.rows[0];
              done();
            } else {
              sql  = "insert into bankrec (bankrec_bankaccnt_id,"       +
                     "  bankrec_opendate, bankrec_openbal"              +
                     ") select bankaccnt_id,"                           +
                     "         current_date - interval '1 month', 100"  +
                     "    from bankaccnt"                               +
                     "    join bankadj   on bankadj_bankaccnt_id = bankaccnt_id"   +
                     "    join bankadjtype on bankadj_bankadjtype_id=bankadjtype_id"+
                     "   limit 1 returning *;";
              datasource.query(sql, adminCred, function (err, res) {
                assert.isNull(err);
                assert.equal(res.rowCount, 1);
                bankrec = res.rows[0];
                done();
              });
            }
          });
        }
      });
    });

    it("needs invalid metrics for testing", function (done) {
      var names = _.map(metricList, function (e) {
                        return "setMetric('" + e.name + "', '-1') as " + e.name;
                      }),
          sql   = "select " + names.join(", ") + ";";
      console.log(sql);
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should fail with invalid bankrec", function (done) {
      var sql = "select importBankrecCleared(-2) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res);
        done();
      });
    });

    it("should fail with invalid Debit Adj", function (done) {
      var sql  = "select importBankrecCleared($1) as result;",
          cred = _.extend({}, adminCred, { parameters: [ bankrec.bankrec_id ]});
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res);
        done();
      });
    });

    it("needs a valid Debit Adj", function (done) {
      var sql  = "select setMetric('ImportBankRecDebitAdj',"                 +
                 "                 bankadjtype_id::text) as result"          +
                 "  from bankadjtype"                                        +
                 "  join bankadj on bankadjtype_id = bankadj_bankadjtype_id" +
                 " where bankadj_bankaccnt_id = $1"                          +
                 " order by bankadjtype_id limit 1;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankrec.bankrec_bankaccnt_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should fail with invalid Credit Adj", function (done) {
      var sql  = "select importBankrecCleared($1) as result;",
          cred = _.extend({}, adminCred, { parameters: [ bankrec.bankrec_id ]});
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res, null, -2);
        done();
      });
    });

    it("needs a valid Credit Adj", function (done) {
      var sql = "select setMetric('ImportBankRecCreditAdj'," +
                "                 bankadjtype_id::text)"     +
                 "  from bankadjtype"                                        +
                 "  join bankadj on bankadjtype_id = bankadj_bankadjtype_id" +
                 " where bankadj_bankaccnt_id = $1"                          +
                 " order by bankadjtype_id limit 1;",
          cred = _.extend({}, adminCred,
                          { parameters: [ bankrec.bankrec_bankaccnt_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should succeed with no bankrecimport", function (done) {
      var sql  = "select importBankrecCleared($1) as result;",
          cred = _.extend({}, adminCred, { parameters: [ bankrec.bankrec_id ]});
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].result, 0);
        done();
      });
    });

    it("needs a bankrecimport to process", function (done) {
      var sql  = "insert into bankrecimport ("                            +
                 "  bankrecimport_reference, bankrecimport_debit_amount," +
                 "  bankrecimport_credit_amount, bankrecimport_effdate,"  +
                 "  bankrecimport_curr_rate"                              +
                 ") values"                                               +
                 "  (now()::text, -123.45, -543.21, current_date, 1)"     +
                 ", (now()::text,  123.45, -543.21, current_date, 1)"     +
                 ", (now()::text, -123.45,  543.21, current_date, 1)"     +
                 ", (now()::text,  123.45,  543.21, current_date, 1)"     +
                 " returning *";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 4);
        bankrecimport = res.rows;
        done();
      });
    });

    it("should succeed with various bankrecimports", function (done) {
      var sql  = "select importBankrecCleared($1) as result;",
          i    = 0;
      _.each(bankrecimport, function (row) {
        var cred = _.extend({}, adminCred,
                            { parameters: [ row.bankrecimport_id ]});
        datasource.query(sql, cred, function (err, res) {
          /*
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].result, 0);
          */
          i++;
          if (i >= bankrecimport.length) { done(); }
        });
      });
    });

    it.skip("needs a posted bankrec");
    it.skip("should fail with posted bankrec", function (done) {
      var sql  = "select importBankrecCleared($1) as result;",
          cred = _.extend({}, adminCred, { parameters: [ bankrec.bankrec_id ]});
      datasource.query(sql, cred, function (err, res) {
        dblib.assertErrorCode(err, res);
        done();
      });
    });

    it("needs to restore those metrics", function (done) {
      var restore = dblib.setMetricsQry(metricList);
      if (restore.update) {
        datasource.query(restore.update, adminCred, function (err /*, res */) {
          assert.isNull(err);
          if (! restore.remove) {
            done();
          }
        });
      }
      if (restore.remove) {
        datasource.query(restore.remove, adminCred, function (err /*, res */) {
          assert.isNull(err);
          done();
        });
      }
      if (! (restore.update || restore.remove)) {
        done();
      }
    });

  });

})();
