var _ = require("underscore"),
  assert = require('chai').assert,
  path = require('path');

(function () {
  "use strict";
  describe('api.invoiceline view', function () {

    var loginData = require(path.join(__dirname, "../../lib/login_data.js")).data,
      datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
      config = require(path.join(__dirname, "../../../node-datasource/config.js")),
      creds = _.extend({}, config.databaseServer, {database: loginData.org});

    function invoiceline(obj) {
      return "ROW('" + obj.invoice_number        + "',"
                     + (obj.line_number           ?       obj.line_number           + ","  : "1,")
                     + (obj.item_number           ? "'" + obj.item_number           + "'," : "NULL,")
                     + (obj.misc_item_number      ? "'" + obj.misc_item_number      + "'," : "NULL,")
                     + (obj.site                  ? "'" + obj.site                  + "'," : "'WH1',")
                     + (obj.misc_item_description ? "'" + obj.misc_item_description + "'," : "NULL,")
                     + (obj.sales_category        ?       obj.sales_category        + "'," : "NULL,")
                     + (obj.customer_part_number  ?       obj.customer_part_number  + "'," : "NULL,")
                     + (obj.qty_ordered           ?       obj.qty_ordered           + ","  : "0,")
                     + (obj.qty_billed            ?       obj.qty_billed            + ","  : "0,")
                     + (obj.update_inventory      ?       obj.update_inventory      + "," : "false,")
                     + (obj.net_unit_price        ? "'" + obj.net_unit_price        + "," : "0,")
                     + (obj.tax_type              ? "'" + obj.tax_type              + "'," : "NULL,")
                     + (obj.qty_uom               ? "'" + obj.qty_uom               + "'," : "NULL,")
                     + (obj.price_uom             ? "'" + obj.price_uom             + "'," : "NULL,")
                     + (obj.notes                 ? "'" + obj.notes                 + "'," : "NULL,")
                     + (obj.alternate_rev_account ? "'" + obj.alternate_rev_account + "'," : "NULL,")
                     + (obj.invoice_subnumber     ? "'" + obj.invoice_subnumber     + "," : "0")
                     + ")"
                     ;
    }

    it("should reject empty input on insert", function (done) {
      var sql = "select insertInvoiceLineItem() as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        done();
      });
    });

    it("should reject insert for non-existent invoice", function (done) {
      var line = invoiceline({invoice_number: 'non-existent'}),
          sql  = "select insertInvoiceLineItem(%) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
        console.error(err);
        assert.isNotNull(err);
        assert.match(err, /xtuple:.*-1[^0-9]|not found/i);
        done();
      });
    });

   

     it("should allow creating a new invoice", function (done) {
      var invoice = "ROW('99999', NULL, NULL, NULL, NULL,"
               +      "NULL, NULL, 0,"
               +      "NULL, NULL, 'TTOYS',"
               +      "NULL, NULL, NULL, NULL, NULL, "
               +      "NULL, NULL, NULL, NULL, NULL, "
               +      "NULL, NULL, NULL, NULL, NULL, "
               +      "NULL, NULL, NULL, NULL, NULL, "
               +      "NULL, NULL, NULL, NULL, NULL, "
               +      "0, NULL, 0, 'USD' , 0, 'invoice notes')",
          sql  = "select insertInvoice(%) as result;".replace(/%/g, invoice)
                 ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });
 
     it("should accept insert for existing invoice", function (done) {
      var line = invoiceline({invoice_number: '99999',
                                 line_number: 1,
                                 qty_ordered: 10,
                                 qty_billed: 5,
                                 notes: 'invoice notes'}),
          sql  = "select insertInvoiceLineItem(%) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

  
    it("should reject update of non-existent invoice", function (done) {
      var line = invoiceline({invoice_number: 'non-existent'}),
          sql  = "select updateInvoiceLineItem(%, %) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        done();
      });
    });

    it("should reject update of non-existent invoice line", function (done) {
      var line = invoiceline({invoice_number: '99999',
                                 line_number: 5,
                                 qty_ordered: 10,
                                 qty_billed: 5,
                                 notes: 'invoice notes'
                                }),
          sql  = "select updateInvoiceLineItem(%, %) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
         console.error(err); 
        assert.isNotNull(err);
        assert.match(err, /xtuple:.*-1[^0-9]|not found/i);
        done();
      });
    });

    it("should accept update of existent invoice line", function (done) {
      var line = invoiceline({invoice_number: '99999',
                                 line_number: 1,
                                 qty_ordered: 10,
                                 qty_billed: 5,
                                 notes: 'invoice notes'
                                }),
          sql  = "select updateInvoiceLineItem(%, %) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isTrue(res.rows[0].result);
        done();
      });
    }); 
 
    after(function (done) {
      var sql = "delete from api.invoice where invoice_number = '99999';";
      datasource.query(sql, creds, done);
    });
  });

}());
