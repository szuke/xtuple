var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('insertSalesLine()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        cohead     = {};

    it("needs a sales order number", function (done) {
      var sql = "select cohead_number, max(coitem_linenumber) AS line"     +
                " from cohead join coitem on cohead_id = coitem_cohead_id" +
                " where cohead_status = 'O'"                               +
                " group by cohead_id limit 1;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        cohead.number  = res.rows[0].cohead_number;
        cohead.maxline = res.rows[0].line;
        done();
      });
    });
    
    it("should insert without error", function (done) {
      var sql = "insert into api.salesline ("                              +
                "        order_number, line_number, item_number,"          +
                "        customer_pn, sold_from_site, status,"             +
                "        qty_ordered, qty_uom, net_unit_price, price_uom," +
                "        scheduled_date,"                                  +
                "        promise_date"                                     +
                ") values ( $1,        $2 + 1,      'YTRUCK1',"            +
                "        'YELLOWTRK',  'WH1',       'O',"                  +
                "        123,          'EA',   12.34,          'EA',"      +
                "        CURRENT_DATE + interval '5 day',"                 +
                "        CURRENT_DATE + interval '7 day'"                  +
                ");",
           cred = _.extend({}, adminCred,
                           { parameters: [ cohead.number, cohead.maxline ] });
      datasource.query(sql, cred, function (err, res) {
        assert.isNull(err);
        done();
      });
    });

    it.skip("verify insertion");
  });

}());
