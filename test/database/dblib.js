(function () {
  'use strict';

  var DEBUG = false,
    _        = require('underscore'),
    async      = require('async'),
    assert     = require('chai').assert,
    loginData  = require('../lib/login_data').data,
    datasource = require('../../node-datasource/lib/ext/datasource').dataSource,
    config     = require('../../node-datasource/config');

  exports.CHARTEXT = 0; // must match qt-client/widgets/characteristicAssignment.cpp
  exports.CHARLIST = 1;
  exports.CHARDATE = 2;
  exports.CHARNUMB = 3;

  exports.datasource = datasource;

  exports.assertErrorCode = function (err, res, funcname, code) {
    if (err) {
      if (funcname) {
        assert.match(err, new RegExp(funcname, "i"), 'standard msg format');
      }
      if (code) {
        assert.match(err, new RegExp("\\W" + code + "\\W"), 'specific error');
      }
    } else {
      assert.equal(res.rowCount, 1);
      assert.operator(res.rows[0].result, "<", 0, 'negative return');
      if (code) {
        assert.equal(res.rows[0].result, code, 'specific error return');
      }
    }
  };

  exports.addUserToGroup = function (user, group, done) {
    var sql = 'select grantGroup($1, grp_id) as ok' +
              '  from grp where grp_name = $2;',
        context = _.extend({}, adminCred, { parameters: [ user, group ] });
    datasource.query(sql, context, function (err, res) {
      assert.isNull(err);
      assert.equal(res.rowCount, 1);
      //assert.isTrue(res.rows[0].ok, 'user should join the group'); // not idempotent
      if (_.isFunction(done)) { done(); }
    });
  };

  /** create an application group and return its id in the result */
  exports.createGroup = function (name, descrip, result, done) {
    var context = _.extend({}, adminCred,
                           { parameters: [ name, descrip || name ] }),
        sql     = 'insert into grp (grp_name, grp_descrip' +
                  ') values ($1, $2) returning grp_id;';
    datasource.query(sql, context, function (err, res) {
      if (err) {
        assert.match(err.code, /23505/);
      } else {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, 'expected one group to be created');
        result = res.rows[0].grp_id;
        assert.isTrue(result >= 0, 'expected a real group id');
      }
      if (_.isFunction(done)) { done(); }
    });
  };

  /** create an application user from a { user: name, password: val, ...} */
  exports.createUser = function (creds, done) {
    var context = _.extend({}, adminCred, { parameters: [ creds.user ] }),
        cu = function () {
          var createSql = 'select createUser($1, false) as result;';
          datasource.query(createSql, context, function (err, res) {
            if (err) {
              assert.match(err.message,
                           /role.*already exists|duplicate key.*usrlite_pkey/,
                           'expect no error creating the user unless it exists');
            } else {
              assert.equal(res.rowCount, 1);
            }
            sp();
          });
        },
        sp = function () {
          var passwdSql = "alter user \"" + creds.user +
                          "\" with password '" + creds.password + "';";
          datasource.query(passwdSql, adminCred, function (err, res) {
//          assert.isNull(err, 'expect no error changing the user password');
//          assert.isNull(res);
            sr();
          });
        },
        sr = function () {
          var xtroleSql = 'alter group xtrole add user "' + creds.user + '";';
          datasource.query(xtroleSql, adminCred, function (err, res) {
//          assert.isNull(err, 'expect no error adding user to xtrole');
//          assert.isNull(res);
            if (_.isFunction(done)) { done(); }
          });
        };
    cu();
  };

  /** @param userdesc {Object,String} either a credentials object or a string */
  exports.deleteUser = function (userdesc, done) {
    var username = userdesc.user || userdesc,
        context  = _.extend({}, adminCred, { parameters: [ username ] }),
        rgp = function () {
          var sql = 'delete from usrgrp where usrgrp_username = $1;';
          datasource.query(sql, context, function (err, res) {
            assert.isNull(err, 'revoking ' + username + ' usrgrp should work');
            rup();
          });
        },
        rup = function () {
          var sql = 'delete from usrpriv where usrpriv_username = $1;';
          datasource.query(sql, context, function (err, res) {
            assert.isNull(err, 'revoking ' + username + ' usrpriv should work');
            dxtu();
          });
        },
        dxtu = function () {
          var sql = 'delete from xt.usrlite where usr_username = $1;';
          datasource.query(sql, context, function (err, res) {
            assert.isNull(err, 'delete ' + username + ' xt.userlite should work');
            du();
          });
        },
        du = function () {
          var sql = 'drop user "' + username + '";';
          datasource.query(sql, adminCred, function (err, res) {
            if (err) {
              assert.match(err, new RegExp("role.*does not exist"), 'should drop ' + username);
            }
            if (_.isFunction(done)) { done(); }
          });
        };
    rgp();
  };

  /**
   *  @param username {String} name to give the user
   *  @param password {String} optional password (defaults to username)
   *  @return login credentials object
   */
  exports.generateCreds = function (username, password) {
    var result = _.extend({}, config.databaseServer, {database: loginData.org});
    if (arguments.length > 0) {
      result.user     = username;
      result.password = username;
    }
    if (arguments.length > 1) {
      result.password = password;
    }
    return result;
  };

  exports.grantPrivToGroup = function (group, priv, done) {
    var sql = 'select grantprivgroup(grp_id, priv_id) as ok' +
              '  from grp, priv'                             +
              ' where grp_name = $1 and priv_name = $2;',
        admin = _.extend({}, adminCred, { parameters: [ group, priv ]});
    datasource.query(sql, admin, function (err, res) {
      assert.equal(res.rowCount, 1, 'expected one priv to be granted');
//    assert.isTrue(res.rows[0].ok, 'expected successful priv granting'); // not idempotent
      if (_.isFunction(done)) { done(); }
    });
  };

  exports.grantPrivToUser = function (creds, priv, done) {
    var sql = 'select grantPriv($1, $2) as result;',
        context = _.extend({}, adminCred, { parameters: [ creds.user, priv ] });
    datasource.query(sql, context, function (err, res) {
      assert.isNull(err, 'should grant ' + priv + ' to ' + creds.user);
      assert.equal(res.rowCount, 1);
      if (_.isFunction(done)) { done(); }
    });
  };

  /* accepts [ { type: 'Value', name: 'MetricName' },
               { type: 'Text',  name: 'MetricName' },
               { type: 'Boolean', name: 'MetricName' }
             ]
     or      [ 'MetricName', 'MetricName', 'MetricName' ]
   */
  exports.getMetricsQry = function (ary) {
    var parts = _.map(ary, function (memo, elem) {
                    var type = (_.isObject(ary[elem]) ? ary[elem].type : "Text"),
                        name = (_.isObject(ary[elem]) ? ary[elem].name : ary[elem]);
                    return "fetchMetric" + type + "('" + name + "') as " + name;
                  }),
        sql   = "select " + parts.join(", ") + ";";
    return sql;
  };

  /* accepts [ { name: 'MetricName', value: newValue }, -- set this value
   *           { name: 'MetricName' }                   -- remove this metric
   *         ]
   */
  exports.setMetricsQry = function (ary) {
    var update = [],
        remove = [],
        result = {};
    _.each(ary, function (elem) {
      if ("value" in elem) {
        update.push("setMetric('" + elem.name + "', '" + elem.value + "'");
      } else if ("name" in elem) {
        remove.push("'" + elem.name + "'");
      } else {
        remove.push("'" + elem + "'");
      }
    });
    if (_.size(update) > 0) {
      result.update = "select " + update.join(", ") + ";";
    }
    if (_.size(remove) > 0) {
      result.remove = "delete from metric where metric_name in (" +
                      remove.join(", ") + ");";
    }
    return result;
  };

  /**
     Create the fiscal year and monthly accounting period records
     for the current year IFF they do not exist.
     @todo add year param
   */
  exports.setUpFiscalYear = function (done) {
    var newPeriodSql = "do $$" + // the loop ensures creation in chron. order
              "declare"                                                      +
              " _this date := date_trunc('year', current_timestamp)::date;"  +
              " _next date;"                                                 +
              " _id   integer;"                                              +
              " _yp   integer;"                                              +
              " begin"                                                       +
              "  select yearperiod_id into _yp from yearperiod"              +
              "   where _this between yearperiod_start and yearperiod_end;"  +
              "  if not found then"                                          +
              "    _yp := createAccountingYearPeriod(_this,"                 +
              "     (_this + interval '1 year' - interval '1 day')::date);"  +
              "  end if;"                                                    +
              "  raise notice 'year %: id %', _this, _yp;"                   +
              "  for _i in 0..11 loop"                                       +
              "    _next := _this + interval '1 month';"                     +
              "    _id := createAccountingPeriod(_this,"                     +
              "                          (_next - interval '1 day')::date,"  +
              "                          _yp, NULL);"                        +
              "    raise notice 'period %: id %', _this, _id;"               +
              "    _this := _next;"                                          +
              "  end loop;"                                                  +
              "end"                                                          +
              "$$;";

    datasource.query(newPeriodSql, adminCred, function (err, res) {
      assert.isNull(err, 'expect no exception from creating periods');
      assert.isNull(res.rowCount, 'expect no result rows');
      if (_.isFunction(done)) { done(); }
    });
  };

  exports.createCreditMemo = function (callback) {
    var sql = "INSERT INTO cmhead (cmhead_number, cmhead_cust_id, cmhead_posted, cmhead_docdate) " +
              "SELECT fetchcmnumber(), cust_id, false, current_date " +
              "FROM custinfo " +
              "WHERE cust_number='TTOYS' " +
              "RETURNING cmhead_id AS result;";

    datasource.query(sql, adminCred, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);

      if (DEBUG)
        console.log("createCreditMemo result: ", res.rows[0].result);

      callback(res.rows[0].result);
    });
  };

  exports.createCreditMemoLineItem = function (params, callback) {
    var sql = "INSERT INTO cmitem ( " +
              " cmitem_cmhead_id, cmitem_linenumber, cmitem_itemsite_id, cmitem_qtyreturned, " +
              " cmitem_qtycredit, cmitem_updateinv, cmitem_qty_uom_id, cmitem_qty_invuomratio, " +
              " cmitem_price_uom_id, cmitem_price_invuomratio, cmitem_unitprice, cmitem_listprice, " +
              " cmitem_taxtype_id, cmitem_comments, " +
              " cmitem_rsncode_id, cmitem_number, cmitem_descrip, cmitem_salescat_id, cmitem_rev_accnt_id ) " +
              "SELECT $1, 1, $2, $3, " +
              " $3, true, item_inv_uom_id, 1, " +
              " item_price_uom_id, 1, 1.99, 1.99, " +
              " (SELECT taxtype_id FROM taxtype LIMIT 1), 'TEST cmitem', " +
              " (SELECT rsncode_id FROM rsncode LIMIT 1), '', '', NULL, NULL " +
              "FROM item JOIN itemsite ON item_id=itemsite_item_id " +
              "WHERE itemsite_id = $4 " +
              "RETURNING cmitem_id AS result; ",
      options = _.extend({}, adminCred,
        { parameters: [ params.cmheadId, params.itemsiteId, params.qty, params.itemsiteId ] });

    datasource.query(sql, options, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);

      if (DEBUG)
        console.log("createCreditMemoLineItem result: ", res.rows[0].result);

      callback(res.rows[0].result);
    });
  };

  exports.createInvoice = function (callback) {
    var sql = "INSERT INTO invchead (invchead_invcnumber, invchead_orderdate, invchead_invcdate, " +
              " invchead_cust_id, invchead_posted, invchead_printed, invchead_commission, " +
              " invchead_freight, invchead_misc_amount, invchead_shipchrg_id) " +
              "VALUES (fetchinvcnumber(), current_date, current_date, " +
              " (SELECT cust_id FROM custinfo WHERE cust_number = 'TTOYS'), false, false, 0, 0, 0, -1) " +
              "RETURNING invchead_id AS result;";

    datasource.query(sql, adminCred, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);
      assert(res.rows[0].result > 0, "invchead_id is > 0");

      if (DEBUG)
        console.log("createInvoice result: ", res.rows[0].result);

      callback(res.rows[0].result);
    });
  };

  exports.createInvoiceLineItem = function (params, callback) {
    var sql = "INSERT INTO invcitem ( " +
              " invcitem_invchead_id, invcitem_item_id, invcitem_warehous_id, " +
              " invcitem_number, invcitem_descrip, invcitem_salescat_id, invcitem_custpn, " +
              " invcitem_ordered, invcitem_billed, invcitem_updateinv, invcitem_qty_uom_id, " +
              " invcitem_qty_invuomratio, invcitem_custprice, invcitem_price, invcitem_listprice, " +
              " invcitem_price_uom_id, invcitem_price_invuomratio, invcitem_notes, " +
              " invcitem_taxtype_id, invcitem_rev_accnt_id) " +
              "SELECT $1::integer, item_id, itemsite_warehous_id, " +
              " '', '', (SELECT salescat_id FROM salescat LIMIT 1), '', " +
              " $2::numeric, $2::numeric, true, item_inv_uom_id, " +
              " 1, 1.99, 1.99, 1.99, " +
              " item_price_uom_id, 1, 'TEST invoice', " +
              " (SELECT taxtype_id FROM taxtype LIMIT 1), NULL " +
              "FROM item " +
              " JOIN itemsite ON itemsite_item_id = item_id " +
              "WHERE itemsite_id = $3::integer " +
              "RETURNING invcitem_id AS result;",
      options = _.extend({}, adminCred,
        { parameters: [ params.invcheadId, params.qty, params.itemsiteId ] });

    datasource.query(sql, options, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);
      //assert(+res.rows[0].result > 0, "invcitem_id is > 0");

      if (DEBUG)
        console.log("createInvoiceLineItem result: ", res.rows[0].result);

      callback(res.rows[0].result);
    });
  };

  exports.createPurchaseOrder = function (callback) {
    var sql = "INSERT INTO pohead (pohead_number, pohead_orderdate, pohead_vend_id, pohead_status) " +
              "SELECT fetchponumber(), current_date, vend_id, 'O' " +
              "FROM vendinfo " +
              "WHERE vend_number='TPARTS' " +
              "RETURNING pohead_id AS result;";

    datasource.query(sql, adminCred, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);

      if (DEBUG)
        console.log("createPurchaseOrder result: ", res.rows[0].result);

      callback(res.rows[0].result);
    });
  };

  exports.createPurchaseOrderLineItem = function (params, callback) {
    var sql = "INSERT INTO poitem (poitem_pohead_id, poitem_itemsite_id, poitem_unitprice, " +
              " poitem_qty_ordered, poitem_duedate) " +
              "SELECT $1, $2, 1.99, $3, current_date " +
              "RETURNING poitem_id AS result; ",
      options = _.extend({}, adminCred,
        { parameters: [ params.poheadId, params.itemsiteId, params.qty ] });

    datasource.query(sql, options, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);

      if (DEBUG)
        console.log("createPurchaseOrderLineItem result: ", res.rows[0].result);

      callback(res.rows[0].result);
    });
  };

  exports.createSalesOrder = function (params, callback) {
    var qryParams = {
      custNumber: 'TTOYS'
    };

    if (typeof params === 'function') {
      callback = params;
    } else {
      qryParams = params;
    }

    var sql = "INSERT INTO cohead (cohead_number, cohead_cust_id, cohead_status)" +
              "SELECT fetchsonumber(), cust_id, 'O'" +
              "  FROM custinfo" +
              " WHERE cust_number = $1" +
              " RETURNING *;";
    var options = _.extend({}, adminCred,
        { parameters: [ qryParams.custNumber ] });

    datasource.query(sql, options, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);

      if (DEBUG)
        console.log("createSalesOrder result: ", res.rows[0]);

      callback(res.rows[0]);
    });
  };

  exports.createSalesOrderLineItem = function (params, callback) {
    var sql = "INSERT INTO coitem (coitem_cohead_id, coitem_itemsite_id, coitem_qtyord, " +
              " coitem_unitcost, coitem_price, coitem_custprice, coitem_qtyshipped, " +
              " coitem_qty_uom_id, coitem_qty_invuomratio, coitem_price_uom_id, " +
              " coitem_price_invuomratio) " +
              "SELECT $1, $2, $3, " +
              " itemcost($2), 1.99, 1.99, 0, " +
              " item_inv_uom_id, 1, item_price_uom_id, " +
              " itemuomratiobytype(item_id, 'Selling') " +
              "FROM itemsite JOIN item ON itemsite_item_id=item_id " +
              "WHERE itemsite_id=$2 " +
              "RETURNING coitem_id AS result; ",
      options = _.extend({}, adminCred,
        { parameters: [ params.coheadId, params.itemsiteId, params.qty ] });

    datasource.query(sql, options, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);

      if (DEBUG)
        console.log("createSalesOrderLineItem result: ", res.rows[0].result);

      callback(res.rows[0].result);
    });
  };

  exports.createWorkOrder = function (params, callback) {
    var sql = "SELECT createWo(fetchwonumber(), $1::integer, 1, $2::numeric, " +
              " current_date, current_date, " +
              " 'TEST WO', '', -1, -1, " +
              " -1, -1, NULL) AS result;",
      options = _.extend({}, adminCred,
        { parameters: [ params.itemsiteId, params.qty ] });

    datasource.query(sql, options, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);

      if (DEBUG)
        console.log("createWorkOrder result: ", res.rows[0].result);

      callback(res.rows[0].result);
    });
  };

  exports.parseMetasql = function (query, params, callback) {
    var sql = "SELECT xt.parsemetasql($1::text, $2::text) AS result;",
        options = _.extend({}, adminCred,
                           { parameters: [ query,
                                           typeof params == 'object' ? JSON.stringify(params) : params
                           ] });
    datasource.query(sql, options, function (err, res) {
      assert.isNull(err);
      assert.isNotNull(res.rows[0].result);
      if (DEBUG)
        console.log("parseMetasql result: ", res.rows[0].result);
      callback(res.rows[0].result);
    });
  };

  var adminCred = exports.adminCred = exports.generateCreds();

}());
