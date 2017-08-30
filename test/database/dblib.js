(function () {
  'use strict';

  var _        = require('underscore'),
    assert     = require('chai').assert,
    loginData  = require('../lib/login_data').data,
    datasource = require('../../node-datasource/lib/ext/datasource').dataSource,
    config     = require('../../node-datasource/config');

  exports.CHARTEXT = 0; // must match qt-client/guiclient/characteristic.h
  exports.CHARLIST = 1;
  exports.CHARDATE = 2;

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

  var adminCred = exports.adminCred = exports.generateCreds();

}());
