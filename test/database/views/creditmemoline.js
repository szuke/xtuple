var _ = require("underscore"),
  assert = require('chai').assert,
  path = require('path');

(function () {
  "use strict";
  describe('api.creditmemoline view', function () {

    var loginData = require(path.join(__dirname, "../../lib/login_data.js")).data,
      datasource = require('../../../node-datasource/lib/ext/datasource').dataSource,
      config = require(path.join(__dirname, "../../../node-datasource/config.js")),
      creds = _.extend({}, config.databaseServer, {database: loginData.org});

    function creditmemoline(obj) {
      return "ROW('" + obj.memo_number        + "',"
               + (obj.line_number ?       obj.line_number        + ","  : "1,")
               + (obj.item_number ? "'" + obj.item_number        + "'," : "NULL,")
               + (obj.recv_site   ? "'" + obj.recv_site          + "'," : "'WH1',")
               + (obj.reason_code ? "'" + obj.reason_code        + "'," : "NULL,")
               + (obj.qty_returned ?      obj.qty_returned       + ","  : "0,")
               + (obj.qty_to_credit ?     obj.qty_to_credit      + ","  : "0,")
               + (obj.qty_uom     ? "'" + obj.qty_uom            + "'," : "NULL,")
               + (obj.net_unit_price ?    obj.net_unit_price     + ","  : "0,")
               + (obj.price_uom   ? "'" + obj.price_uom          + "'," : "NULL,")
               + (obj.tax_type    ? "'" + obj.tax_type           + "'," : "NULL,")
               + (obj.notes       ? "'" + obj.notes              + "'"  : "NULL")
               + ")"
               ;
    }

    it("should reject empty input on insert", function (done) {
      var sql = "select insertcreditmemoline() as result;";
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        done();
      });
    });

    it("should reject insert for non-existent credit memo", function (done) {
      var line = creditmemoline({memo_number: 'non-existent'}),
          sql  = "select insertcreditmemoline(%) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /xtuple:.*-1[^0-9]|not found/i);
        done();
      });
    });

    it("should allow creating a new credit memo", function (done) {
      var memo = "ROW('99999', NULL, NULL, NULL, NULL, 0,"
               +      "NULL, NULL, FALSE, 'TTOYS',"
               +      "NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,"
               +      "NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,"
               +      "NULL, 'credit memo notes', 'USD', NULL, NULL,"
               +      "NULL, 1)",
          sql  = "select insertcreditmemo(%) as result;".replace(/%/g, memo)
                 ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("should accept insert for existing credit memo", function (done) {
      var line = creditmemoline({memo_number: '99999',
                                 line_number: 1,
                                 item_number: 'YTRUCK1',
                                 reason_code: 'SO-DAMAGED-RETURNED',
                                 qty_to_credit: 5
                                }),
          sql  = "select insertcreditmemoline(%) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    it("should reject update of non-existent memo", function (done) {
      var line = creditmemoline({memo_number: 'non-existent'}),
          sql  = "select updatecreditmemoline(%, %) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        done();
      });
    });

    it("should reject update of non-existent credit memo line", function (done) {
      var line = creditmemoline({memo_number: '99999',
                                 line_number: 5,
                                 item_number: 'YTRUCK1',
                                 reason_code: 'SO-DAMAGED-RETURNED',
                                 qty_to_credit: 5
                                }),
          sql  = "select updatecreditmemoline(%, %) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNotNull(err);
        assert.match(err, /xtuple:.*-1[^0-9]|not found/i);
        done();
      });
    });

    it("should accept update of existent credit memo line", function (done) {
      var line = creditmemoline({memo_number: '99999',
                                 line_number: 1,
                                 item_number: 'YTRUCK1',
                                 reason_code: 'SO-DAMAGED-RETURNED',
                                 qty_to_credit: 1
                                }),
          sql  = "select updatecreditmemoline(%, %) as result;".replace(/%/g, line)
        ;
      datasource.query(sql, creds, function (err, res) {
        assert.isNull(err);
        assert.isTrue(res.rows[0].result);
        done();
      });
    });

    after(function (done) {
      var sql = "delete from api.creditmemo where memo_number = '99999';";
      datasource.query(sql, creds, done);
    });
  });

}());
