var _       = require('underscore'),
    assert  = require('chai').assert;

(function () {
  'use strict';

  describe('crmacct trigger', function () {

    var dblib      = require('../dblib.js'),
        adminCred  = dblib.adminCred,
        casualUser = 'crmaccttest',
        casualCred = dblib.generateCreds(casualUser),
        crmacctid  = -1,
        datasource = dblib.datasource,
        emailAcct,
        emailUser  = "TestUser",
        emailAddr  = emailUser + "@xTuple.com";

    function cleanup(done) {
      var deleteCasualCredfunction = function () {
        dblib.deleteUser(casualCred, deleteEmailUserfunction);
      };
      var deleteEmailUserfunction = function () {
        dblib.deleteUser(emailUser.toLowerCase(), deleteEmailAddrfunction);
      };
      var deleteEmailAddrfunction = function () {
        dblib.deleteUser(emailAddr.toLowerCase(), deleteAccountsfunction);
      };
      var deleteAccountsfunction = function () {
        var accounts = [
          'TESTY',
          emailAddr.toUpperCase(),
          emailUser.toUpperCase()
        ];
        accounts.forEach(function (acct, index) {
            var deleteSql = [
              "delete from vendinfo where vend_number    = $1;",
              "delete from custinfo where cust_number    = $1;",
              "delete from crmacct  where crmacct_number = $1;"
            ];
            deleteSql.forEach(function (sql, deleteIndex) {
              var cred = _.extend({}, adminCred, { parameters: [ acct ] });
              datasource.query(sql, cred, function (err, res) {
                assert.isNull(err);
                assert.isNotNull(res);

                if (index === accounts.length - 1 && deleteIndex === deleteSql.length - 1) {
                  done();
                }
              });
            });
        });
      };

      deleteCasualCredfunction();
    }

    before(cleanup);
    after(cleanup);

    it('needs a test user', function (done) {
      dblib.createUser(casualCred, done);
    });

    it('needs test user to have MaintainCustomerMasters', function (done) {
      dblib.grantPrivToUser(casualCred, 'MaintainCustomerMasters', done);
    });

    it('needs test user to have MaintainAllCRMAccounts', function (done) {
      dblib.grantPrivToUser(casualCred, 'MaintainAllCRMAccounts', done);
    });

    it('needs a test xTC user', function (done) {
      dblib.createUser(dblib.generateCreds(emailAddr.toLowerCase()), done);
    });

    it('unprivileged user should create a Customer', function (done) {
      var sql = "insert into custinfo ("                                +
                "  cust_number, cust_name, cust_active, cust_backorder" +
                ", cust_autoholdorders, cust_discntprcnt"               +
                ", cust_partialship, cust_balmethod"                    +
                ", cust_autoupdatestatus, cust_ffshipto, cust_ffbillto" +
                ", cust_blanketpos, cust_usespos"                       +
                ", cust_custtype_id"                                    +
                ", cust_salesrep_id"                                    +
                ", cust_terms_id"                                       +
                ", cust_shipchrg_id"                                    +
                ") values ("                                            +
                "  'TESTY', 'Test CRM Account', true, true"             +
                ", false, 0"                                            +
                ", true, 'B'"                                           +
                ", true, false, false"                                  +
                ", false, true"                                         +
                ", (select min(custtype_id) from custtype)"             +
                ", (select min(salesrep_id) from salesrep)"             +
                ", (select min(terms_id) from terms)"                   +
                ", (select min(shipchrg_id) from shipchrg)"             +
                ") returning cust_number;";

      datasource.query(sql, casualCred, function (err, res) {
        assert.isNull(err, 'user should be able to create a Customer');
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("should verify the crm account exists", function (done) {
      var sql = "select crmacct_id from crmacct where crmacct_number = 'TESTY';";
      datasource.query(sql, adminCred, function (err, res) {
        assert.equal(res.rowCount, 1, 'there should be a new CRM Account, too');
        crmacctid = res.rows[0].crmacct_id;
        assert.isTrue(crmacctid >= 0, 'the new CRM Account should have an id');
        done();
      });
    });

    it("unprivileged user should change the crm account name", function (done) {
      var sql = "update crmacct set crmacct_name = crmacct_name || ' Change'" +
                " where crmacct_id = $1 returning crmacct_id;",
          options = _.extend({}, casualCred, { parameters: [ crmacctid ]});
      datasource.query(sql, options, function (err, res) {
        assert.equal(res.rowCount, 1, 'one crmaccount should change names');
        done();
      });
    });

    it("should verify the account and customer changed", function (done) {
      var sql = "select crmacct_name, cust_name"                            +
                "  from crmacct join custinfo on crmacct_cust_id = cust_id" +
                " where crmacct_id = $1;",
          options = _.extend({}, adminCred, { parameters: [ crmacctid ]});
      datasource.query(sql, options, function (err, res) {
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].cust_name, res.rows[0].crmacct_name,
                     'names should match after the change');
        assert.equal(res.rows[0].cust_name, 'Test CRM Account Change',
                     'both names should have the new value');
        done();
      });
    });

    it("should create a vendor for this crm account", function (done) {
      var sql = "insert into vendinfo ("                      +
                "  vend_number, vend_name"                    +
                ", vend_vendtype_id"                          +
                ", vend_terms_id"                             +
                ") values ("                                  +
                "  'TESTY', 'Test CRM Account Change'"        +
                ", (select min(vendtype_id) from vendtype)"   +
                ", (select min(terms_id) from terms)"         +
                ") returning vend_number;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err, 'expect no error creating the vendor');
        assert.equal(res.rowCount, 1);
        done();
      });
    });

    it("unprivileged user should fail changing the crm account name", function (done) {
      var sql = "update crmacct set crmacct_name = 'Test CRM Account Trigger'" +
                " where crmacct_id = $1 returning crmacct_id;",
          options = _.extend({}, casualCred, { parameters: [ crmacctid ]});
      datasource.query(sql, options, function (err, res) {
        assert.isNotNull(err, 'expect a Vendor error changing the CRM Account now');
        assert.isUndefined(res);
        done();
      });
    });

    it('should grant MaintainVendors priv', function (done) {
      dblib.grantPrivToUser(casualCred, 'MaintainVendors', done);
    });

    it("unprivileged user should change the crm account name", function (done) {
      var sql = "update crmacct set crmacct_name = 'Test CRM Account Trigger'" +
                " where crmacct_id = $1 returning crmacct_id;",
          options = _.extend({}, casualCred, { parameters: [ crmacctid ]});
      datasource.query(sql, options, function (err, res) {
        assert.isNull(err, 'the user should now be able to change the CRM Account');
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].crmacct_id, crmacctid);
        done();
      });
    });

    it("should verify the account, cust, vend all changed", function (done) {
      var sql = "select crmacct_name, cust_name, vend_name"     +
                "  from crmacct"                                +
                "  join custinfo on crmacct_cust_id = cust_id"  +
                "  join vendinfo on crmacct_vend_id = vend_id"  +
                " where crmacct_id = $1;",
          options = _.extend({}, adminCred, { parameters: [ crmacctid ]});
      datasource.query(sql, options, function (err, res) {
        assert.equal(res.rowCount, 1,
                     'the CRM Account should match both Customer and Vendor');
        assert.equal(res.rows[0].crmacct_name, res.rows[0].cust_name,
                     'the Customer name should match');
        assert.equal(res.rows[0].crmacct_name, res.rows[0].vend_name,
                     'the Vendor name should match');
        assert.equal(res.rows[0].crmacct_name, 'Test CRM Account Trigger',
                     'the shared name should be the new one');
        done();
      });
    });

    it("should allow creating a CRM Account for a User", function (done) {
      var sql = "insert into crmacct ("                                +
                "  crmacct_number, crmacct_name, crmacct_usr_username" +
                ") values ("                                           +
                "  $1, $1, $1"                                         +
                ") returning *;",
          options = _.extend({}, adminCred, { parameters: [ emailAddr ]});
      datasource.query(sql, options, function (err, res) {
        assert.equal(res.rowCount, 1);
        emailAcct = res.rows[0];
        assert.equal(emailAcct.crmacct_number,       emailAddr.toUpperCase());
        assert.equal(emailAcct.crmacct_usr_username, emailAddr.toLowerCase());
        done();
      });
    });

    it("should allow changing a User crmacct's number", function (done) {
      var sql = "update crmacct"                +
                "   set crmacct_number = $1"    +
                " where crmacct_id = $2"        +
                " returning *;",
          options = _.extend({}, adminCred,
                             { parameters: [ emailUser, emailAcct.crmacct_id ]});
      datasource.query(sql, options, function (err, res) {
        assert.equal(res.rowCount, 1, 'one crmaccount should change');
        assert.equal(res.rows[0].crmacct_number,       emailUser.toUpperCase());
        assert.equal(res.rows[0].crmacct_usr_username, emailUser.toLowerCase());
        assert.equal(res.rows[0].crmacct_name,         emailAddr);
        done();
      });
    });

    it("should verify the user changed", function (done) {
      var sql = "select usr_username"   +
                "  from usr"            +
                " where usr_username = lower($1);",
          options = _.extend({}, adminCred, { parameters: [ emailUser ]});
      datasource.query(sql, options, function (err, res) {
        assert.equal(res.rowCount, 1);
        done();
      });
    });

  });
})();

