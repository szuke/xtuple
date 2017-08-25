/* 
  Inventory Adjustment diffs, per control type and qty:

  Lot + Location controlled item:
    (+):
      - source: 
      - itemlocdist_source_type = 'O'

      - child(ren): 
      (lot records)
      - itemlocdist_source_type = 'O'
      - itemlocdist_source_id = parent.itemlocdist_id
      - itemlocdist_series = NEXTVAL('itemloc_series_seq')
      - itemlocdist_itemlocdist_id = NULL
      
      (location records)
      - itemlocdist_source_type = 'L'
      - itemlocdist_source_id = location_id
      - itemlocdist_series = NULL
      - itemlocdist_itemlocdist_id = lot record's itemlocdist_id
    (-):
      - source:

      - child(ren):
      - itemlocdist_source_type = 'I'
      - itemlocdist_source_id = location_id
      - itemlocdist_series = NULL
      - itemlocdist_itemlocdist_id = parent.itemlocdist_id

  Location controlled item:
    (+):
      - source:
      - itemlocdist_source_type = 'O'

      - child(ren):
      - itemlocdist_source_type = 'L'
      - itemlocdist_source_id = location_id
      - itemlocdist_series = NULL
      - itemlocdist_itemlocdist_id = parent.itemlocdist_id
    (-):
      - source:
      - itemlocdist_source_type = 'O'

      - child(ren)
      - itemlocdist_source_type = 'I'
      - itemlocdist_source_id = itemloc_id
      - itemlocdist_series = NULL
      - itemlocdist_itemlocdist_id = parent.itemlocdist_id

  Lot/Serial controlled item:
    (+):
      - source: 
      - itemlocdist_source_type = 'O'

      - child(ren): 
      - itemlocdist_source_type = 'L'
      - itemlocdist_source_id = -1
      - itemlocdist_itemlocdist_id = NULL
      - itemlocdist_series = NEXTVAL('itemloc_series_seq')
    (-):
      - source:
      - itemlocdist_source_type = 'O'

      - child(ren): 
      - itemlocdist_source_type = 'I'
      - itemlocdist_source_id = itemloc_id
      - itemlocdist_itemlocdist_id = parent.itemlocdist_id
      - itemlocdist_series = NULL

*/

var _ = require("underscore"),
  assert = require('chai').assert,
  invAdjustment = function (itemNumber, qty) {
    "use strict";
    assert.isNotNull(itemNumber);
    assert.isNotNull(qty);
    
    describe('Inventory Adjustment transaction', function () {
      var loginData = require("../lib/login_data.js").data,
        datasource = require('../../node-datasource/lib/ext/datasource').dataSource,
        config     = require("../../node-datasource/config.js"),
        creds = _.extend({}, config.databaseServer, {database: loginData.org}),
        qohBefore,
        itemsiteId,
        itemlocSeries,
        newSeries,
        itemlocdistId,
        invhistId, 
        lotCntrld, 
        locCntrld,
        sourceType = qty < 0 ? 'I' : 'L',
        sourceId;
      this.timeout(10*1000);

      before(function(done) {
        var sql = "SELECT NEXTVAL('itemloc_series_seq') AS itemloc_series, itemsite_id, " + 
                  " itemsite_loccntrl, itemsite_controlmethod IN ('L', 'S') AS lscntrl, itemsite_qtyonhand "           +
                  "FROM itemsite "                                        +
                  " JOIN item ON itemsite_item_id = item_id "             +
                  " JOIN warehous ON itemsite_warehous_id = warehous_id " +
                  "WHERE item_number = $1 AND warehous_code = 'WH1' "     +
                  "LIMIT 1",
          options = _.extend({}, creds,
              { parameters: [ itemNumber ] });

        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].itemsite_id.valueOf(), ">", 0);
          qohBefore = res.rows[0].itemsite_qtyonhand.valueOf();
          itemlocSeries = res.rows[0].itemloc_series.valueOf();
          itemsiteId = res.rows[0].itemsite_id.valueOf();
          locCntrld = res.rows[0].itemsite_loccntrl.valueOf();
          lotCntrld = res.rows[0].lscntrl.valueOf();
          done();
        });
      });

      it('sets the source id for the transaction', function (done) {
        if (!locCntrld && !lotCntrld) { return done(); }
        var sql;
        if (qty < 0) {
          sql = "SELECT itemloc_id AS id FROM itemloc " +
                "WHERE itemloc_itemsite_id = $1 " +
                " AND itemloc_qty > 0 " +
                "ORDER BY itemloc_qty DESC LIMIT 1";
        } else if (qty > 0) {
          sql = "SELECT location_id AS id " +
                "FROM location " +
                "WHERE validlocation(location_id, $1) LIMIT 1";
        }

        var options = _.extend({}, creds,
          { parameters: [ itemsiteId ] });

        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          sourceId = res.rows[0].id.valueOf();
          done();
        });
      });

      it('should create a parent itemlocdist record', function (done) {
        if (!lotCntrld && !locCntrld) { return done(); }
        var sql = "SELECT createitemlocdistparent($1::INTEGER, $2::NUMERIC, 'AD'::TEXT, " +
                  " NULL, $3::INTEGER, NULL::INTEGER) AS result; ",
          options = _.extend({}, creds,
            { parameters: [ itemsiteId, qty, itemlocSeries ] });

        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].result.valueOf(), ">", 0);
          itemlocdistId = res.rows[0].result.valueOf();
          done();
        });
      });

      it('create lot/serial if ls controlled item', function (done) {
        if (!lotCntrld) { return done(); }
        datasource.query("SELECT NEXTVAL('itemloc_series_seq') AS result; ", creds, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].result.valueOf(), ">", 0);
          newSeries = res.rows[0].result.valueOf();
        
          var sql = "SELECT createlotserial($1::integer, $2::text, $3::integer, " +
                  " 'I'::text, NULL::integer, itemlocdist_id::integer, $4::numeric, " +
                  " endOfTime()::date, NULL::date) AS result " + 
                  "FROM itemlocdist WHERE (itemlocdist_id=$5);",
            options = _.extend({}, creds,
              { parameters: [ itemsiteId, 'TESTLOT1', newSeries, qty, itemlocdistId ] });
          datasource.query(sql, options, function (err, res) {
            assert.isNull(err);
            assert.equal(res.rowCount, 1);
            assert.operator(res.rows[0].result.valueOf(), ">", 0);
            done();
          });
        });
      });

      it('update itemlocdist record if ls controlled item and qty > 0', function (done) {
        if (!lotCntrld || qty < 0 || locCntrld) { return done(); }
        console.log("newSeries: ", newSeries);
        var sql = "UPDATE itemlocdist " +
                  "SET itemlocdist_source_type='L', itemlocdist_source_id = -1 " +
                  "WHERE (itemlocdist_series=$1);",
          options = _.extend({}, creds,
            { parameters: [ newSeries ] });
        datasource.query(sql, options, function (err, res) {
          assert.isNull(err); 
          assert.equal(res.rowCount, 1);
          done();
        });
      });

      it('create itemlocdist (child) record for location controlled item', function (done) {
        if (!locCntrld) { return done(); }
        var sql = "INSERT INTO itemlocdist " +
                  "( itemlocdist_itemlocdist_id, " +
                  "  itemlocdist_source_type, itemlocdist_source_id, " +
                  "  itemlocdist_qty, itemlocdist_ls_id, itemlocdist_expiration ) " +
                  "SELECT itemlocdist_id, " +
                  " $1, $2, $3, itemlocdist_ls_id, endOfTime() " +
                  "FROM itemlocdist " +
                  "WHERE itemlocdist_series=$4 " +
                  "RETURNING itemlocdist_id, itemlocdist_qty;",
          options = _.extend({}, creds,
            { parameters: [ sourceType, sourceId, qty, itemlocSeries ] });

          datasource.query(sql, options, function (err, res) {
            assert.isNull(err);
            assert.equal(res.rowCount, 1);
            assert.operator(res.rows[0].itemlocdist_id.valueOf(), ">", 0);
            done();
          });
      });

      // For location (+) trans, child records, itemlocdist_series is null. 
      // Update the parent record to have itself as itemlocdist_series.
      it('update itemlocdist with new child series', function (done) {
        if (!locCntrld && !lotCntrld) { return done(); }
        var sql = "UPDATE itemlocdist " +
                  "SET itemlocdist_child_series = COALESCE($1::INTEGER, $2::INTEGER) " +
                  "WHERE itemlocdist_series = $2::INTEGER AND $2::INTEGER IS NOT NULL " +
                  "RETURNING itemlocdist_id;",
          options = _.extend({}, creds,
            { parameters: [ newSeries, itemlocSeries ] });

        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].itemlocdist_id.valueOf(), ">", 0);
          done();
        });
      });

      it('call invadjustment function, save invhist_id', function (done) {
        var sql = "SELECT invAdjustment($1, $2, '', '', now(), NULL, NULL, $3, TRUE) AS result;",
          options = _.extend({}, creds,
            { parameters: [ itemsiteId, qty, itemlocSeries ] });

        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.operator(res.rows[0].result.valueOf(), ">", 0);
          done();
        });
      });

      it('check that qoh changed', function (done) {
        var sql = "SELECT itemsite_qtyonhand " +
                  "FROM itemsite " + 
                  "WHERE itemsite_id = $1;",
          options = _.extend({}, creds,
            { parameters: [ itemsiteId ] });

        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.equal(res.rows[0].itemsite_qtyonhand.valueOf(), (qohBefore + qty));
          done();
        });
      });

      it('check that inventory (distribution) detail record exists', function (done) {
        if (!locCntrld && !lotCntrld) { return done(); }
        var sql = "SELECT 1 " +
                  "FROM itemsite " + 
                  " JOIN invhist on itemsite_id = invhist_itemsite_id " +
                  " JOIN invdetail on invhist_id = invdetail_invhist_id " +
                  "WHERE invhist_itemsite_id = $1 " +
                  " AND invhist_series = $2;",
          options = _.extend({}, creds,
            { parameters: [ itemsiteId, itemlocSeries ] });

        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          done();
        });
      });


      it('verify that the itemlocdist records were deleted through postitemlocseries.sql function',
        function (done) {
        var sql = "SELECT 1 FROM getAllItemlocdist($1);",
          options = _.extend({}, creds,
            { parameters: [ itemlocSeries ] });

        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 0);
          done();
        });
      });
    });
  };

// non-controlled item
describe('create + transaction for non-controlled BTRUCK1', function () {
  invAdjustment('BTRUCK1', 1);
});

describe('create - transaction for non-controlled BTRUCK1', function () {
  invAdjustment('BTRUCK1', -1);
});

// location controlled item
describe('create + transaction for location controlled WTRUCK1', function () {
  invAdjustment('WTRUCK1', 1);
});

describe('create - transaction for location controlled WTRUCK1', function () {
  invAdjustment('WTRUCK1', -1);
});

// Lot controlled item
describe('create + transaction for location & lot controlled RPAINT1', function () {
  invAdjustment('RPAINT1', 1);
});

// TODO
describe('create - transaction for location & lot controlled RPAINT1', function () {
  invAdjustment('RPAINT1', -1);
});

// TODO
// location and serial controlled item
describe('create + transaction for location controlled STRUCK1', function () {
  invAdjustment('STRUCK1', 1);
});

// location and serial controlled item
describe('create - transaction for location controlled STRUCK1', function () {
  invAdjustment('STRUCK1', -1);
});
