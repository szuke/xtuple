var _      = require("underscore"),
    assert = require('chai').assert,
    dblib  = require('../dblib');

(function () {
  "use strict";

  describe('voidInvoice()', function () {

    var datasource = dblib.datasource,
        adminCred  = dblib.generateCreds(),
        id         = {},
        itemlocseries, numUnpostedInvHist;
        ;

    // TODO: the need for coalesce(invcitem_updateinv) implies a bug
    it("needs one posted and one unposted invoice", function (done) {
      var sql = "select min(invchead_id) as invchead_id, invchead_posted," +
                "       min(aropen_id) as aropen_id,"                      +
                "       min(arapply_id) as arapply_id,"                    +
                "       arapply_id is not null as arapplyexists,"          +
                "       invcitem_billed > 0 and coalesce(invcitem_updateinv, false) as hasinv" +
                "  from invchead"                                          +
                "  join invcitem on invchead_id = invcitem_invchead_id"    +
                "  join aropen on aropen_doctype = 'I'"                    +
                "             and aropen_docnumber = invchead_invcnumber"  +
                "  join cohist on cohist_doctype = 'I'"                    +
                "             and cohist_invcnumber = invchead_invcnumber" +
                "  left outer join arapply on"                             +
                "                  aropen_id = arapply_target_aropen_id"   +
                " group by invchead_posted, arapplyexists, hasinv;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.operator(res.rowCount, ">",  0); // expect true, false
        assert.operator(res.rowCount, "<=", 3); // & perhaps NULL
        _.each(res.rows, function (e) {
          if (e.invchead_posted === false)   { id.unposted = e.invchead_id; }
          else if (e.arapplyexists === true) { id.applied  = e.invchead_id; }
          else if (e.hasinv === true)        { id.hasinv   = e.invchead_id; }
          else                               { id.posted   = e.invchead_id; }
        });
        done();
      });
    });

    it("needs the number of unposted invhist records", function (done) {
      var sql = "SELECT COUNT(*) AS num FROM invhist WHERE NOT invhist_posted;";
      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        numUnpostedInvHist = res.rows[0].num;
        done();
      });
    });

    it("should fail for invalid invoice", function (done) {
      var sql = "select voidInvoice(-5) as result;";
      datasource.query(sql, adminCred, function (err, res) {
        dblib.assertErrorCode(err, res, 'voidInvoice');
        done();
      });
    });

    it("should fail for an unposted invoice", function (done) {
      if (id.unposted) {
        var sql = "select voidInvoice($1) as result;",
            cred = _.extend({}, adminCred, { parameters: [ id.unposted ] });
        datasource.query(sql, cred, function (err, res) {
          dblib.assertErrorCode(err, res, 'voidInvoice', -10);
          done();
        });
      } else {
        console.log("did not find an unposted invoice");
        done();
      }
    });

    it("should fail for an applied invoice", function (done) {
      if (id.applied) {
        var sql = "select voidInvoice($1) as result;",
            cred = _.extend({}, adminCred, { parameters: [ id.applied ] });
        datasource.query(sql, cred, function (err, res) {
          dblib.assertErrorCode(err, res, 'voidInvoice', -20);
          done();
        });
      } else {
        console.log("did not find an applied invoice");
        done();
      }
    });

    it("should succeed for a posted invoice with inventory updates", function (done) {
      if (id.hasinv) {
        var sql = "select voidInvoice($1) as result;",
            cred = _.extend({}, adminCred, { parameters: [ id.hasinv ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          itemlocseries = res.rows[0].result;
          assert.operator(itemlocseries, ">", 0);
          done();
        });
      } else {
        console.log("did not find a posted invoice with inventory updates");
        done();
      }
    });

    it("needs the itemlocseries posted", function (done) {
      if (id.hasinv) {
        var sql     = "SELECT postItemLocSeries($1) AS result;",
            options = _.extend({}, adminCred, { parameters: [ itemlocseries ]});
        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.isTrue(res.rows[0].result);
          done();
        });
      } else {
        console.log("did not find a posted invoice with inventory updates");
        done();
      }
    });

    it("should have updated the invchead for inventory updates", function (done) {
      if (id.hasinv) {
        var sql = "select invchead_void, invchead_notes" +
                  "  from invchead where invchead_id = $1;",
            cred = _.extend({}, adminCred, { parameters: [ id.hasinv ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.isTrue(res.rows[0].invchead_void, "marked void");
          assert.match(res.rows[0].invchead_notes, /Voided on .* by/);
          done();
        });
      } else {
        console.log("did not find a posted invoice with inventory updates");
        done();
      }
    });

    it("should succeed for posted invoices w/out inv updates", function (done) {
      if (id.posted) {
        var sql = "select voidInvoice($1) as result;",
            cred = _.extend({}, adminCred, { parameters: [ id.posted ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          itemlocseries = res.rows[0].result;
          assert.operator(itemlocseries, ">", 0);
          done();
        });
      } else {
        console.log("did not find a posted invoice without inventory updates");
        done();
      }
    });

    it("might `need the invoice itemlocseries posted w/out inv updates", function (done) {
      if (id.posted) {
        var sql     = "SELECT postItemLocSeries($1) AS result;",
            options = _.extend({}, adminCred, { parameters: [ itemlocseries ]});
        datasource.query(sql, options, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.isTrue(res.rows[0].result);
          done();
        });
      } else {
        console.log("did not find a posted invoice without inventory updates");
        done();
      }
    });

    it("should have updated the invchead w/out inv updates", function (done) {
      if (id.posted) {
        var sql = "select invchead_void, invchead_notes" +
                  "  from invchead where invchead_id = $1;",
            cred = _.extend({}, adminCred, { parameters: [ id.posted ] });
        datasource.query(sql, cred, function (err, res) {
          assert.isNull(err);
          assert.equal(res.rowCount, 1);
          assert.isTrue(res.rows[0].invchead_void, "marked void");
          assert.match(res.rows[0].invchead_notes, /Voided on .* by/);
          done();
        });
      } else {
        console.log("did not find a posted invoice with inventory updates");
        done();
      }
    });

    it.skip("should have affected gltrans by the value of the invoice");
    it.skip("should have deleted cohisttax");
    it.skip("should have deleted cohist");
    it.skip("should have inserted into aropen");
    it.skip("should have inserted into arapply");
    it.skip("should have posted inventory transactions");
    it.skip("should have opened coitems");
    it.skip("should have updated shipitems");
    it.skip("should have updated cobill");
    it.skip("should have updated cobmisc");
    it.skip("should fail if not exists ... where aropen_doctype = 'I' and aropen_docnumber = invchead_invcnumber");
    it.skip("should fail -11 if sales account assignment does not exist");
    it.skip("should fail -14 if there is freight but no freight account assignment");
    it.skip("should fail -14 if there is misc_amount but no misc account");
    it.skip("should fail if insertIntoGLSeries fails");

    it("there should be no new unposted invhist records", function (done) {
      var sql = "SELECT COUNT(*) AS num FROM invhist WHERE NOT invhist_posted;";

      datasource.query(sql, adminCred, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1);
        assert.equal(res.rows[0].num, numUnpostedInvHist);
        done();
      });
    });

  });

}());
