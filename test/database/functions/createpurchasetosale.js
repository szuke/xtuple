/* jshint laxbreak:true */
var _      = require('underscore'),
    assert = require('chai').assert;

(function () {
  'use strict';
  describe('convertPurchaseToSale()', function () {

    var loginData  = require('../../lib/login_data.js').data,
        datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
        config     = require('../../../node-datasource/config.js'),
        creds      = _.extend({}, config.databaseServer,
                              { database: loginData.org }),
        headchar_id,
        linechar_id,
        cohead_id,
        coitem,
        poitem_id;

    before(function (done) {
      var sql = "DELETE FROM charass USING char"
              + " WHERE char_name IN ('TestHead', 'TestLine')"
              + "  AND charass_char_id = char_id;"
              + "DELETE FROM charuse USING char"
              + " WHERE char_name IN ('TestHead', 'TestLine')"
              + "  AND charuse_char_id = char_id;"
              + "SELECT deleteCharacteristic(char_id) FROM char"
              + " WHERE char_name IN ('TestHead', 'TestLine');";
      datasource.query(sql, creds, done);
    });

    it('needs characteristics for head level', function (done) {
      var sql = "INSERT INTO char (char_name, char_notes, char_type)"
              + " VALUES ('TestHead', 'freeform order-head level characteristic', 0)"
              + " RETURNING char_id;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        headchar_id = res.rows[0].char_id;
        done();
      });
    });

    it('needs characteristics for item level', function (done) {
      var sql = "INSERT INTO char (char_name, char_notes, char_type)"
              + " VALUES ('TestLine', 'freeform lineitem level characteristic', 0)"
              + " RETURNING char_id;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        linechar_id = res.rows[0].char_id;
        done();
      });
    });

    it('needs charuse for head- and item-level', function (done) {
      var sql = "INSERT INTO charuse (charuse_char_id, charuse_target_type)"
              + " VALUES (" + headchar_id + ", 'SO'),"
              + "        (" + headchar_id + ", 'PO'),"
              + "        (" + linechar_id + ", 'SI'),"
              + "        (" + linechar_id + ", 'PI')"
              + " RETURNING charuse_id;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount >= 4);
        done();
      });
    });

    it('needs a sales order to convert', function (done) {
      var sql = "INSERT INTO cohead ("
              + "       cohead_number,"
              + "       cohead_cust_id,"
              + "       cohead_orderdate,"
              + "       cohead_shipto_id,"
              + "       cohead_shiptoname,"
              + "       cohead_shiptoaddress1,"
              + "       cohead_shiptoaddress2,"
              + "       cohead_shiptoaddress3,"
              + "       cohead_salesrep_id,"
              + "       cohead_terms_id,"
              + "       cohead_shipvia,"
              + "       cohead_shiptocity,"
              + "       cohead_shiptostate,"
              + "       cohead_shiptozipcode,"
              + "       cohead_freight,"
              + "       cohead_ordercomments,"
              + "       cohead_shiptophone,"
              + "       cohead_commission,"
              + "       cohead_packdate,"
              + "       cohead_shiptocountry,"
              + "       cohead_curr_id,"
              + "       cohead_taxzone_id,"
              + "       cohead_status,"
              + "       cohead_saletype_id,"
              + "       cohead_shipzone_id"
              + ") SELECT "
              + "       fetchsonumber(),"
              + "       cust_id,"
              + "       CURRENT_DATE,"
              + "       shipto_id,"
              + "       shipto_name,"
              + "       sta.addr_line1,"
              + "       sta.addr_line2,"
              + "       sta.addr_line3,"
              + "       COALESCE(shipto_salesrep_id, cust_salesrep_id),"
              + "       cust_terms_id,"
              + "       shipto_shipvia,"
              + "       sta.addr_city,"
              + "       sta.addr_state,"
              + "       sta.addr_postalcode,"
              + "       1.00,"
              + "       'Test converting Sales Order to Purchase Order',"
              + "       COALESCE(stc.cntct_phone, btc.cntct_phone),"
              + "       0.025,"
              + "       NULL,"
              + "       sta.addr_country,"
              + "       cust_curr_id,"
              + "       shipto_taxzone_id,"
              + "       'O',"
              + "       1,"
              + "       shipto_shipzone_id"
              + "  FROM custinfo"
              + "  JOIN shiptoinfo ON cust_id        = shipto_cust_id"
              + "  JOIN addr sta   ON shipto_addr_id = sta.addr_id"
              + "  LEFT OUTER JOIN cntct stc ON shipto_cntct_id = stc.cntct_id"
              + "  LEFT OUTER JOIN cntct btc ON cust_cntct_id   = btc.cntct_id"
              + " LIMIT 1"
              + " RETURNING cohead_id;"
              ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        cohead_id = res.rows[0].cohead_id;
        done();
      });
    });

    it('needs at least one sales order characteristic', function (done) {
      var sql = "INSERT INTO charass ("
              + "       charass_target_type,"
              + "       charass_target_id,"
              + "       charass_char_id,"
              + "       charass_value"
              + ") SELECT"
              + "       'SO',"
              +         cohead_id + ","
              + "       char_id,"
              + "       'abc'"
              + "  FROM char"
              + "  JOIN charuse ON char_id = charuse_char_id"
              + "             AND charuse_target_type = 'SO'"
              + " WHERE char_type = 0"
              + " RETURNING charass_id"
              + ";"
              ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount > 0, "expected at least one SO charass");
        done();
      });
    });

    it('needs at least one sales order line item', function (done) {
      var sql = "INSERT INTO coitem ("
              + "       coitem_cohead_id,"
              + "       coitem_linenumber,"
              + "       coitem_itemsite_id,"
              + "       coitem_scheddate,"
              + "       coitem_qtyord,"
              + "       coitem_qtyshipped,"
              + "       coitem_unitcost,"
              + "       coitem_price,"
              + "       coitem_custprice,"
              + "       coitem_memo,"
              + "       coitem_custpn,"
              + "       coitem_prcost,"
              + "       coitem_qty_uom_id,"
              + "       coitem_qty_invuomratio,"
              + "       coitem_price_uom_id,"
              + "       coitem_price_invuomratio,"
              + "       coitem_taxtype_id"
              + ") SELECT "
              +         cohead_id + ","
              + "       (SELECT COALESCE(MIN(coitem_linenumber), 0) + 1"
              + "          FROM coitem WHERE coitem_cohead_id = " + cohead_id + "),"
              + "       itemsite_id,"
              + "       CURRENT_DATE + '15 days'::INTERVAL,"
              + "       123.45,"
              + "       0,"
              + "       itemCost(itemsite_id),"
              + "       itemPrice(item_id, cohead_cust_id, cohead_shipto_id, 123.45,"
              + "                 item_inv_uom_id, item_price_uom_id, cohead_curr_id,"
              + "                 cohead_orderdate, CURRENT_DATE, NULL),"
              + "       itemPrice(item_id, cohead_cust_id, cohead_shipto_id, 123.45,"
              + "                 item_inv_uom_id, item_price_uom_id, cohead_curr_id,"
              + "                 cohead_orderdate, CURRENT_DATE, NULL),"
              + "       'test item',"
              + "       'customer part number',"
              + "       1.23,"
              + "       item_inv_uom_id,"
              + "       1,"
              + "       item_price_uom_id,"
              + "       itemuomtouomratio(item_id, item_inv_uom_id, item_price_uom_id),"
              + "       cohead_taxtype_id"
              + "  FROM cohead"
              + "  JOIN itemsite ON cohead_warehous_id = itemsite_warehous_id"
              + "  JOIN item     ON itemsite_item_id   = item_id"
              + "  JOIN itemsrc  ON item_id            = itemsrc_item_id"
              + "  JOIN charass  ON charass_target_id  = item_id"
              + "             AND charass_target_type = 'I'"
              + " WHERE cohead_id = " + cohead_id
              + " LIMIT 1"
              + " RETURNING *"
              + ";"
              ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        coitem = res.rows;
        assert(res.rowCount > 0, "expected at least one sales order item");
        done();
      });
    });

    it('needs at least one sales line characteristic', function (done) {
      var sql = "INSERT INTO charass ("
              + "       charass_target_type,"
              + "       charass_target_id,"
              + "       charass_char_id,"
              + "       charass_value"
              + ") SELECT"
              + "       'SI',"
              + "       coitem_id,"
              + "       char_id,"
              + "       'abc'"
              + "  FROM coitem,"
              + "       char"
              + "  JOIN charuse ON char_id = charuse_char_id"
              + "             AND charuse_target_type = 'SI'"
              + " WHERE char_type = 0"
              + "  AND coitem_cohead_id = " + cohead_id
              + " RETURNING charass_id"
              + ";"
              ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount > 0, "expected at least one SI charass");
        done();
      });
    });

    it('should run without error', function (done) {
      var sql = "SELECT createPurchaseToSale(" + coitem[0].coitem_id + ","
              + "       (SELECT itemsrc_id FROM itemsrc"
              + "          JOIN itemsite ON itemsrc_item_id = itemsite_item_id"
              + "         WHERE itemsite_id = " + coitem[0].coitem_itemsite_id
              + "         LIMIT 1"
              + "       ), false) AS result"
              + ";";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        poitem_id = res.rows[0].result;
        assert(poitem_id > 0);
        done();
      });
    });

    it('should have created pohead characteristics', function (done) {
      var sql = "SELECT charass_id"
              + "  FROM charass"
              + "  JOIN char   ON charass_char_id = char_id AND char_name = 'TestHead'"
              + "  JOIN poitem ON charass_target_id = poitem_pohead_id"
              + "             AND charass_target_type = 'PO'"
              + " WHERE poitem_id = " + poitem_id + ";";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, "expected pohead to have TestHead characteristic");
        done();
      });
    });

    it('should have created poitem characteristics', function (done) {
      var sql = "SELECT charass_id"
              + "  FROM charass"
              + "  JOIN char ON charass_char_id = char_id AND char_name = 'TestLine'"
              + " WHERE charass_target_type = 'PI'"
              + "   AND charass_target_id = " + poitem_id + ";";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, "expected poitem to have TestLine characteristic");
        done();
      });
    });

    after(function (done) {
      var sql = "SELECT deleteSO("   + cohead_id   + ") AS deleteq;";
      datasource.query(sql, creds, done);
    });

    after(function (done) {
      var sql = "SELECT deletePo(poitem_pohead_id) AS deletep"
              + "  FROM poitem"
              + " WHERE poitem_id = " + poitem_id + ";";
      datasource.query(sql, creds, done);
    });

  });
})();
