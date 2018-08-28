/* jshint laxbreak:true */
var _      = require('underscore'),
    assert = require('chai').assert;

(function () {
  'use strict';
  describe('convertPurchaseToQuote()', function () {

    var loginData  = require('../../lib/login_data.js').data,
        datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
        config     = require('../../../node-datasource/config.js'),
        creds      = _.extend({}, config.databaseServer,
                              { database: loginData.org }),
        headchar_id,
        linechar_id,
        quhead_id,
        quitem,
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
              + " VALUES (" + headchar_id + ", 'QU'),"
              + "        (" + headchar_id + ", 'PO'),"
              + "        (" + linechar_id + ", 'QI'),"
              + "        (" + linechar_id + ", 'PI')"
              + " RETURNING charuse_id;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount >= 4);
        done();
      });
    });

    it('needs a quote to convert', function (done) {
      var sql = "INSERT INTO quhead ("
              + "       quhead_number,"
              + "       quhead_cust_id,"
              + "       quhead_custponumber,"
              + "       quhead_quotedate,"
              + "       quhead_warehous_id,"
              + "       quhead_shipto_id,"
              + "       quhead_shiptoname,"
              + "       quhead_shiptoaddress1,"
              + "       quhead_shiptoaddress2,"
              + "       quhead_shiptoaddress3,"
              + "       quhead_salesrep_id,"
              + "       quhead_terms_id,"
              + "       quhead_fob,"
              + "       quhead_shipvia,"
              + "       quhead_shiptocity,"
              + "       quhead_shiptostate,"
              + "       quhead_shiptozipcode,"
              + "       quhead_freight,"
              + "       quhead_misc,"
              + "       quhead_ordercomments,"
              + "       quhead_shipcomments,"
              + "       quhead_shiptophone,"
              + "       quhead_billtoname,"
              + "       quhead_billtoaddress1,"
              + "       quhead_billtoaddress2,"
              + "       quhead_billtoaddress3,"
              + "       quhead_billtocity,"
              + "       quhead_billtostate,"
              + "       quhead_billtozip,"
              + "       quhead_misc_accnt_id,"
              + "       quhead_misc_descrip,"
              + "       quhead_commission,"
              + "       quhead_packdate,"
              + "       quhead_prj_id,"
              + "       quhead_billtocountry,"
              + "       quhead_shiptocountry,"
              + "       quhead_curr_id,"
              + "       quhead_taxzone_id,"
              + "       quhead_imported,"
              + "       quhead_expire,"
              + "       quhead_status,"
              + "       quhead_saletype_id,"
              + "       quhead_shipzone_id"
              + ") SELECT "
              + "       fetchqunumber(),"  //'00002',"
              + "       cust_id,"
              + "       'Test Purchase to Quote',"
              + "       CURRENT_DATE,"
              + "       CASE shipto_preferred_warehous_id WHEN -1 THEN NULL"
              + "                    ELSE shipto_preferred_warehous_id END,"
              + "       shipto_id,"
              + "       shipto_name,"
              + "       sta.addr_line1,"
              + "       sta.addr_line2,"
              + "       sta.addr_line3,"
              + "       COALESCE(shipto_salesrep_id, cust_salesrep_id),"
              + "       cust_terms_id,"
              + "       'fob',"
              + "       shipto_shipvia,"
              + "       sta.addr_city,"
              + "       sta.addr_state,"
              + "       sta.addr_postalcode,"
              + "       1.00,"
              + "       2.00,"
              + "       'Test converting Quote to Invoice',"
              + "       'shipping notes',"
              + "       COALESCE(stc.cntct_phone, btc.cntct_phone),"
              + "       cust_name,"
              + "       bta.addr_line1,"
              + "       bta.addr_line2,"
              + "       bta.addr_line3,"
              + "       bta.addr_city,"
              + "       bta.addr_state,"
              + "       bta.addr_postalcode,"
              + "       (SELECT accnt_id FROM accnt LIMIT 1),"
              + "       'Misc Charge',"
              + "       0.025,"
              + "       NULL,"
              + "       (SELECT prj_id FROM prj LIMIT 1),"
              + "       bta.addr_country,"
              + "       sta.addr_country,"
              + "       cust_curr_id,"
              + "       shipto_taxzone_id,"
              + "       true,"
              + "       CURRENT_DATE + '30 days'::INTERVAL,"
              + "       'O',"
              + "       1,"
              + "       shipto_shipzone_id"
              + "  FROM custinfo"
              + "  JOIN shiptoinfo ON cust_id        = shipto_cust_id"
              + "  JOIN addr sta   ON shipto_addr_id = sta.addr_id"
              + "  LEFT OUTER JOIN cntct stc ON shipto_cntct_id = stc.cntct_id"
              + "  LEFT OUTER JOIN cntct btc ON cust_cntct_id   = btc.cntct_id"
              + "  LEFT OUTER JOIN addr  bta ON btc.cntct_addr_id = bta.addr_id"
              + " LIMIT 1"
              + " RETURNING quhead_id;"
              ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        quhead_id = res.rows[0].quhead_id;
        done();
      });
    });

    it('needs at least one quote characteristic', function (done) {
      var sql = "INSERT INTO charass ("
              + "       charass_target_type,"
              + "       charass_target_id,"
              + "       charass_char_id,"
              + "       charass_value"
              + ") SELECT"
              + "       'QU',"
              +         quhead_id + ","
              + "       char_id,"
              + "       'abc'"
              + "  FROM char"
              + "  JOIN charuse ON char_id = charuse_char_id"
              + "             AND charuse_target_type = 'QU'"
              + " WHERE char_type = 0"
              + " RETURNING charass_id"
              + ";"
              ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount > 0, "expected at least one QU charass");
        done();
      });
    });

    it('needs at least one quote line item', function (done) {
      var sql = "INSERT INTO quitem ("
              + "       quitem_quhead_id,"
              + "       quitem_linenumber,"
              + "       quitem_itemsite_id,"
              + "       quitem_scheddate,"
              + "       quitem_qtyord,"
              + "       quitem_unitcost,"
              + "       quitem_price,"
              + "       quitem_custprice,"
              + "       quitem_memo,"
              + "       quitem_custpn,"
              + "       quitem_createorder,"
              + "       quitem_order_warehous_id,"
              + "       quitem_item_id,"
              + "       quitem_prcost,"
              + "       quitem_qty_uom_id,"
              + "       quitem_qty_invuomratio,"
              + "       quitem_price_uom_id,"
              + "       quitem_price_invuomratio,"
              + "       quitem_promdate,"
              + "       quitem_taxtype_id,"
              + "       quitem_itemsrc_id"
              + ") SELECT "
              +         quhead_id + ","
              + "       1,"
              + "       itemsite_id,"
              + "       quhead_expire,"
              + "       123.45,"
              + "       itemCost(itemsite_id),"
              + "       itemPrice(item_id, quhead_cust_id, quhead_shipto_id, 123.45,"
              + "                 item_inv_uom_id, item_price_uom_id, quhead_curr_id,"
              + "                 quhead_quotedate, CURRENT_DATE, NULL),"
              + "       itemPrice(item_id, quhead_cust_id, quhead_shipto_id, 123.45,"
              + "                 item_inv_uom_id, item_price_uom_id, quhead_curr_id,"
              + "                 quhead_quotedate, CURRENT_DATE, NULL),"
              + "       'test item',"
              + "       'customer part number',"
              + "       false,"
              + "       quhead_warehous_id,"
              + "       item_id,"
              + "       1.23,"
              + "       item_inv_uom_id,"
              + "       1,"
              + "       item_price_uom_id,"
              + "       itemuomtouomratio(item_id, item_inv_uom_id, item_price_uom_id),"
              + "       quhead_expire,"
              + "       quhead_taxtype_id,"
              + "       itemsrc_id"
              + "  FROM quhead"
              + "  JOIN itemsite ON quhead_warehous_id = itemsite_warehous_id"
              + "  JOIN item     ON itemsite_item_id   = item_id"
              + "  JOIN itemsrc  ON item_id            = itemsrc_item_id"
              + "  JOIN charass  ON charass_target_id  = item_id"
              + "             AND charass_target_type = 'I'"
              + " WHERE quhead_id = " + quhead_id
              + " LIMIT 2"
              + " RETURNING *"
              + ";"
              ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        quitem = res.rows;
        done();
      });
    });

    it('needs at least one quote line characteristic', function (done) {
      var sql = "INSERT INTO charass ("
              + "       charass_target_type,"
              + "       charass_target_id,"
              + "       charass_char_id,"
              + "       charass_value"
              + ") SELECT"
              + "       'QI',"
              + "       quitem_id,"
              + "       char_id,"
              + "       'abc'"
              + "  FROM quitem,"
              + "       char"
              + "  JOIN charuse ON char_id = charuse_char_id"
              + "             AND charuse_target_type = 'QI'"
              + " WHERE char_type = 0"
              + "  AND quitem_quhead_id = " + quhead_id
              + " RETURNING charass_id"
              + ";"
              ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert(res.rowCount > 0, "expected at least one QI charass");
        done();
      });
    });

    it('should run without error', function (done) {
      var sql = "SELECT createPurchaseToQuote(" + quitem[0].quitem_id
              + "," + quitem[0].quitem_itemsrc_id + ", false) AS result;";
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
              + "  JOIN char   ON charass_char_id = char_id"
              + "             AND char_name = 'TestHead'"
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
      var sql = "SELECT deleteQuote("   + quhead_id   + ") AS deleteq;";
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
