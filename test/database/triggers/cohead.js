var _    = require('underscore'),
  assert = require('chai').assert,
  dblib  = require('../dblib');

(function () {
  'use strict';

  describe('cohead trigger(s) test', function () {
    var datasource  = dblib.datasource,
        adminCred   = dblib.generateCreds(),
        casualCred  = dblib.generateCreds('casualUser'),
        salesCred   = dblib.generateCreds('salesUser'),
        recvCred    = dblib.generateCreds('receivingUser'),
        shipCred    = dblib.generateCreds('shippingUser'),
        start       = new Date(),
        testTag     = 'cohead trigger test ' + start.toLocaleTimeString(),
        orders      = {}
        ;

    // set up /////////////////////////////////////////////////////////////////
    describe('setup', function () {
      it('should create casual user', function (done) {
        dblib.createUser(casualCred, done);
      });
      it('should create sales user', function (done) {
        dblib.createUser(salesCred, done);
      });
      it('should create receiving user', function (done) {
        dblib.createUser(recvCred, done);
      });
      it('should create shipping user', function (done) {
        dblib.createUser(shipCred, done);
      });

      it('should grant MaintainSalesOrders', function (done) {
        dblib.grantPrivToUser(salesCred, 'MaintainSalesOrders',   done);
      });
      it('should grant EnterReceipts', function (done) {
        dblib.grantPrivToUser(recvCred,  'EnterReceipts',         done);
      });
      it('should grant IssueStockToShipping', function (done) {
        dblib.grantPrivToUser(shipCred,  'IssueStockToShipping', done);
      });
    });

    after(function () {
      dblib.deleteUser(shipCred);
      dblib.deleteUser(recvCred);
      dblib.deleteUser(salesCred);
      dblib.deleteUser(casualCred);
    });

    describe('priv checks', function () {
      var newSOSql = "INSERT INTO cohead (cohead_number, cohead_cust_id,"      +
                 "    cohead_orderdate, cohead_packdate,"                      +
                 "    cohead_shipto_id, cohead_shiptoname,"                    +
                 "    cohead_shiptoaddress1, cohead_shiptoaddress2,"           +
                 "    cohead_shiptoaddress3, cohead_shiptocity,"               +
                 "    cohead_shiptostate, cohead_shiptozipcode,"               +
                 "    cohead_shiptocountry, cohead_ordercomments,"             +
                 "    cohead_salesrep_id, cohead_terms_id, cohead_holdtype,"   +
                 "    cohead_freight, cohead_calcfreight,"                     +
                 "    cohead_shipto_cntct_id, cohead_shipto_cntct_first_name," +
                 "    cohead_shipto_cntct_last_name,"                          +
                 "    cohead_curr_id, cohead_taxzone_id, cohead_taxtype_id,"   +
                 "    cohead_saletype_id,"                                     +
                 "    cohead_shipvia,"                                         +
                 "    cohead_shipchrg_id,"                                     +
                 "    cohead_shipzone_id, cohead_shipcomplete"                 +
                 ") SELECT fetchSoNumber(), cust_id,"                          +
                 "    CURRENT_DATE, CURRENT_DATE,"                             +
                 "    shipto_id, shipto_name,"                                 +
                 "    addr_line1, addr_line2,"                                 +
                 "    addr_line3, addr_city,"                                  +
                 "    addr_state, addr_postalcode,"                            +
                 "    addr_country, $1,"                                       +
                 "    cust_salesrep_id, cust_terms_id, 'N',"                   +
                 "    0, TRUE,"                                                +
                 "    cntct_id, cntct_first_name, cntct_last_name,"            +
                 "    cust_curr_id, shipto_taxzone_id, taxass_taxtype_id,"     +
                 "    (SELECT saletype_id FROM saletype"                       +
                 "      WHERE saletype_code='REP'),"                           +
                 "    (SELECT MIN(shipvia_code) FROM shipvia),"                +
                 "    (SELECT shipchrg_id FROM shipchrg"                       +
                 "      WHERE shipchrg_name='ADDCHARGE'),"                     +
                 "    shipto_shipzone_id, FALSE"                               +
                 "  FROM custinfo"                                             +
                 "  JOIN shiptoinfo ON cust_id=shipto_cust_id"                 +
                 "                 AND shipto_active"                          +
                 "  JOIN taxass ON shipto_taxzone_id=taxass_taxzone_id"        +
                 "  JOIN taxrate ON taxass_tax_id=taxrate_tax_id"              +
                 "  LEFT OUTER JOIN addr ON shipto_addr_id=addr_id"            +
                 "  LEFT OUTER JOIN cntct ON shipto_cntct_id=cntct_id"         +
                 " WHERE cust_active"                                          +
                 "   AND cust_preferred_warehous_id > 0"                       +
                 "   AND (taxrate_percent > 0 OR taxrate_amount > 0)"          +
                 " LIMIT 1 RETURNING *;",
          updateSOSql = 'UPDATE cohead SET cohead_shipvia=$1' +
                        ' WHERE cohead_id = $2 RETURNING cohead_shipvia;',
          shipvia = [ 'FedEx', 'UPS', 'USPS', 'DHL', 'Werner', 'ABF' ],
          shipviaCounter = 0
          ;

      it('should allow admin user to create an order', function (done) {
        var options = _.extend({}, adminCred,
                               { parameters: [ testTag ] });
        datasource.query(newSOSql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          orders.admin = res.rows[0];
          done();
        });
      });

      it('should allow sales user to create an order', function (done) {
        var options = _.extend({}, salesCred,
                               { parameters: [ testTag ] });
        datasource.query(newSOSql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          orders.sales = res.rows[0];
          done();
        });
      });

      it('should allow recv user to create an order', function (done) {
        var options = _.extend({}, recvCred,
                               { parameters: [ testTag ] });
        datasource.query(newSOSql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          orders.recv = res.rows[0];
          done();
        });
      });

      it('should not allow casual user to create an order', function (done) {
        var options = _.extend({}, casualCred,
                               { parameters: [ testTag ] });
        datasource.query(newSOSql, options, function (err, res) {
          assert.isNotNull(err, 'expected an error');
          assert.isUndefined(res);
          done();
        });
      });

      it('should not allow shipping user to create an order', function (done) {
        var options = _.extend({}, shipCred,
                               { parameters: [ testTag ] });
        datasource.query(newSOSql, options, function (err, res) {
          assert.isNotNull(err);
          assert.isUndefined(res);
          done();
        });
      });

      it('should allow admin user to update an order', function (done) {
        var options = _.extend({}, adminCred,
                               { parameters: [ shipvia[shipviaCounter],
                                               orders.admin.cohead_id ] });
        datasource.query(updateSOSql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(shipvia[shipviaCounter], res.rows[0].cohead_shipvia);
          shipviaCounter++;
          done();
        });
      });

      it('should allow sales user to update an order', function (done) {
        var options = _.extend({}, salesCred,
                               { parameters: [ shipvia[shipviaCounter],
                                               orders.sales.cohead_id ] });
        datasource.query(updateSOSql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(shipvia[shipviaCounter], res.rows[0].cohead_shipvia);
          shipviaCounter++;
          done();
        });
      });

      it('should allow recv user to update an order', function (done) {
        var options = _.extend({}, recvCred,
                               { parameters: [ shipvia[shipviaCounter],
                                               orders.recv.cohead_id ] });
        datasource.query(updateSOSql, options, function (err, res) {
          assert.isNotNull(err);
          assert.isUndefined(res);
          done();
        });
      });

      it('should not allow casual user to update an order', function (done) {
        var options = _.extend({}, casualCred,
                               { parameters: [ shipvia[shipviaCounter],
                                               orders.admin.cohead_id ] });
        datasource.query(updateSOSql, options, function (err, res) {
          assert.isNotNull(err);
          assert.isUndefined(res);
          done();
        });
      });

      it('should allow shipping user to update an order', function (done) {
        var options = _.extend({}, shipCred,
                               { parameters: [ shipvia[shipviaCounter],
                                               orders.admin.cohead_id ] });
        datasource.query(updateSOSql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(shipvia[shipviaCounter], res.rows[0].cohead_shipvia);
          shipviaCounter++;
          done();
        });
      });

    });

  });
}());
