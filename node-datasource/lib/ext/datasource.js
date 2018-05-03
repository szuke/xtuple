/*jshint indent:2, curly:true, eqeqeq:true, immed:true, latedef:true,
newcap:true, noarg:true, regexp:true, undef:true, strict:true, trailing:true,
white:true*/
/*global XT:true, console:true, issue:true, require:true, XM:true, io:true,
Backbone:true, _:true, X:true, __dirname:true, exports:true, module: true */

(function () {
  "use strict";

  require('../../xt/');

  var pg = require("pg");

  /*
   * Updated versions of `node-postgres` no longer automatically parses `bigint`
   * and `numeric` datatypes in JavaScript. This is because JavaScript's
   * `Number` class cannot accurately represent very large numbers. We add back
   * in the parsing so these values come back from queries as numbers and not
   * strings like the old versions did automatically.
   *
   * @see
   * https://github.com/brianc/node-postgres/issues/339
   * https://github.com/brianc/node-postgres/pull/353#issuecomment-19117695
   * https://github.com/brianc/node-pg-types#use
   *
   * TODO: Proper large number support in JavaScript requires adding a library
   * to our stack and using it everywhere. The `decimal.js` library is an option
   * used by `Math.js`. There may soon be support in native JavaScript that can
   * help:
   * @see
   * https://v8project.blogspot.com/2018/05/bigint.html
   *
   * @see
   * https://github.com/MikeMcl/decimal.js
   * https://github.com/josdejong/mathjs
   */
  pg.types.setTypeParser(20, function(val) {
    return parseInt(val); // The `int8` type.
  });
  pg.types.setTypeParser(1700, function (value) {
    return parseFloat(value); // The `numeric` type.
  });

  var RJSON = require("rjson"),
    path = require('path'),
    _ = require("underscore"),
    EventEmitter = require('events').EventEmitter,
    DataSource = {
      requestNum: 0,
      callbacks: {},

      creds : {},

      getAdminCredentials: function (organization) {
        return {
          user: X.options.databaseServer.user,
          host: X.options.databaseServer.hostname,
          port: X.options.databaseServer.port,
          database: organization,
          password: X.options.databaseServer.password
        };
      },

      /**
      * Encode the server's response into the encoding specified by the client
      * @see enyo-client/application/source/ext/datasource.js#decodeResponse
      */
      encodeResponse: function (result, encoding) {
        if (!encoding) {
          return result;
        }
        else if (encoding === "rjson") {
          return RJSON.pack(result);
        }
        else {
          return {
            isError: true,
            status: "Encoding [" + encoding + "] not recognized."
          };
        }
      },

      /**
      * Initializes database by setting the default pool size
      */
      init: function () {
        var that = this;

        pg.defaults.poolSize = this.poolSize;
      },

      /**
        Perform query

        @param {String} query
        @param {Object} options
        @param {Function} callback
      */
      query: function (query, options, callback) {
        this.creds = {
          "user": options.user,
          "port": options.port,
          "host": options.host || options.hostname,
          "database": options.database,
          "password": options.password
        };

        if (X.options && X.options.datasource && X.options.datasource.pgWorker) {
          this.requestNum += 1;

          this.callbacks[this.requestNum] = callback;
          // Single worker version.
          options.debugDatabase = X.options.datasource.debugDatabase;
          this.worker.send({id: this.requestNum, query: query, options: options, creds: this.creds, poolSize: this.poolSize});

          // NOTE: Round robin benchmarks are slower then the above single pgworker code.
          // Round robin workers version. This might be useful in the future.
          // var worker = this.workers[this.nextWorker];
          // this.nextWorker += 1;
          // if (this.nextWorker === this.workers.length) {
          //   this.nextWorker = 0;
          // }
          // options.debugDatabase = X.options.datasource.debugDatabase;
          // worker.send({id: this.requestNum, query: query, options: options, creds: this.creds});
        } else {
          if (X.options && query.indexOf('select xt.delete($${"nameSpace":"SYS","type":"SessionStore"') < 0 &&
              query.indexOf('select xt.get($${"nameSpace":"SYS","type":"SessionStore"') < 0) {
            X.capture(query);
            X.debug(query);
          }
          pg.connect(this.creds, _.bind(this.connected, this, query, options, callback));
        }
      },

      /**
      * Connected.
      *
      * NOTE: This is only used when not using a seperate pgWorker process.
      * It's useful if you need to run the node-inspector debugger which breaks on multiple processes.
      * See: https://github.com/dannycoates/node-inspector/issues/130
      * You can also just run, "kill -USR1 12345", to start the debugger on a running process
      * instead of starting node with the debugger running: "sudo node --debug-brk main.js".
      */
      connected: function (query, options, callback, err, client, done) {
        if (err) {
          X.exception.handle(X.warning("Failed to connect to database: " +
            "{host}:{port}/{database} => %@".f(options, err.message)));
          done();
          return callback(err);
        }

        // If we got a client that was flagged to be destroyed, try again.
        if (client.destroying) {
          this.query(query, options, callback);
          return;
        }

        var that = this,
          queryCallback,
          errorHandlerCount = EventEmitter.listenerCount(client.connection, 'error'),
          noticeHandlerCount = EventEmitter.listenerCount(client.connection, 'notice');

        client.status = [];
        client.debug = [];

        // Register error handler to log errors.
        if (errorHandlerCount < 2) {
          client.connection.on('error', function (msg) {
            var lastQuery;

            if (msg.message !== "handledError") {
              X.err("Database Error! ", msg.message + " Please fix this!!!");
              _.each(client.debug, function (message) {
                X.err("Database Error! DB message was: ", message);
              });
              lastQuery = that.activeQuery && that.activeQuery.length > 10000 ?
                "Too long to print (" + that.activeQuery.length + " chars) " +
                "but starts with " + that.activeQuery.substring(0, 1000) :
                that.activeQuery;
              X.err("Database Error! Last query was: ", lastQuery);
              X.err("Database Error! DB name = ", options.database);
            }
          });
        }

        if (noticeHandlerCount < 2) {
          client.connection.on('notice', function (msg) {
            if (msg && msg.message) {
              if (msg.severity === 'NOTICE') {
                client.status.push(msg.message);
                //console.log("Database notice Message: ", msg.message);
              } else if (msg.severity === 'INFO') {
                client.status.push(msg.message);
                //console.log("Database info Message: ", msg.message);
              } else if (msg.severity === 'WARNING') {
                client.debug.push(msg.message);
                //console.log("Database warning Message: ", msg.message);
              } else if (msg.severity === 'DEBUG') {
                client.debug.push(msg.message);
                //console.log("Database debug Message: ", msg.message);
              }
            }
          });
        }

        queryCallback = function (err, result) {
          if (err) {
            // Set activeQuery for error event handler above.
            that.activeQuery = client.activeQuery ? client.activeQuery.text : 'unknown. See PostgreSQL log.';
          }

          if (client.status && client.status.length) {
            if (result) {
              try {
                result.status = JSON.parse(client.status[0]);
              } catch (error) {
                // Move on, no status message to set. We only want JSON messages here.
              }
            } else if (err) {
              try {
                err.status = JSON.parse(client.status[0]);
              } catch (error) {
                // Move on, no status message to set. We only want JSON messages here.
              }
            } else {
              console.log("### FIX ME ### No result or err returned for query. This shouldn't happen.");
              console.trace("### At this location ###");
            }

            if (client.status.length > 1) {
              try {
                JSON.parse(client.status);
                console.log("### FIX ME ### Database is returning more than 1 message status. This shouldn't happen.");
                console.log("### FIX ME ### Status is: ", JSON.stringify(client.status));
                console.log("### FIX ME ### Query was: ", client.activeQuery ? client.activeQuery.text : 'unknown. See PostgreSQL log.');
                console.trace("### At this location ###");
              } catch (error) {
                // Move on, no status message to set. We only want JSON messages here.
              }
            }
          }
          if (client.debug && client.debug.length) {
            if (result) {
              result.debug = client.debug;
            } else if (err) {
              err.debug = client.debug;
            } else {
              console.log("### FIX ME ### No result or err returned for query. This shouldn't happen.");
              console.trace("### At this location ###");
            }
          }

          // Release the client from the pool.
          if (err) {
            /**
             * The package, `node-postgres`, we use maintains a connection pool
             * to the database server, defaulting to 10 connections.
             *
             * We make use of plv8's `SET plv8.start_proc = 'xt.js_init'
             * feature for those connections. This is only called the FIRST time
             * a plv8 function is called for a connection. Because of this, if a
             * connection, when added to the pool happens to cause an error in
             * the database during its first transaction that uses plv8, all of
             * the steps we do for a persistent client connection in
             * `xt.js_init();` are rolled back. The main thing we setup is the
             * `search_path`. If an error happens on the first query for this
             * connection, the `search_path` will not be set the next time the
             * pool's connection is used for a query.
             *
             * Because of this, on any emitted errors below in `connected()`, we
             * destroy that client from the pool.
             */

            // Set flag so we don't use this client above before it's removed.
            client.destroying = true;

            done(err);

            // Now that the client has been destroyed, for the pool to function
            // correctly, we need to add one back to take its place.
            // @see: https://github.com/brianc/node-postgres/issues/1460
            pg.pools.all[JSON.stringify(that.creds)].acquire(function (newErr, newClient) {
              // But we don't actually need it, so release it back to the pool.
              pg.pools.all[JSON.stringify(that.creds)].release(newClient);

              // Once the client has been added to the pool, call the callback.
              callback(err, result);
            });
          } else {
            done();

            // Call the callback.
            callback(err, result);
          }

        };

        // node-postgres supports parameters as a second argument. These will be options.parameters
        // if they're there.
        if (options.parameters) {
          client.query(query, options.parameters, queryCallback);
        } else {
          client.query(query, queryCallback);
        }
      },

      /*
      Server request

      @param {Object} model or collection
      @param {String} method
      @param {Object} payload
      @param {Object} options
      */
      request: function (obj, method, payload, options) {
        var that = this,
          conn = X.options.databaseServer,
          isDispatch = _.isObject(payload.dispatch),
          query,
          complete = function (err, response) {
            var dataHash,
              params = {},
              error,
              attrs;

            // Handle error
            if (err) {
              if (options && options.error) {
                params.error = err;
                error = XT.Error.clone('xt1001', { params: params });
                options.error.call(that, error);
              }
              return;
            }

            dataHash = JSON.parse(response.rows[0].request);

            // Handle no data as error
            if (method === "get" && options.id &&
              _.isEmpty(dataHash.data)) {
              if (options && options.error) {
                error = XT.Error.clone('xt1007');
                options.error.call(obj, error);
              }
              return;
            }

            // Handle success
            if (options && options.success) {
              if (isDispatch) {
                options.success(dataHash, options);
                return;
              }
              if (dataHash.patches) {
                attrs = obj ?
                    XM.jsonpatch.apply(obj.toJSON(), dataHash.patches) :
                    dataHash.patches;
              } else {
                attrs = dataHash.data;
              }
              if (obj) {
                obj.etag = dataHash.etag;
              }
              options.success.call(that, obj, attrs, options);
            }
          };

        payload.username = options.username;
        payload.encryptionKey = X.options.encryptionKey;
        payload = JSON.stringify(payload);
        query = "select xt.{method}($${payload}$$) as request"
                .replace("{method}", method)
                .replace("{payload}", payload);

        if (options.database) {
          conn.database = options.database;
        } else {
          console.log("### FIX ME ### calling XT.dataSource.request with payload = ", JSON.stringify(payload));
          console.log("### FIX ME ### call needs to set database in options!!!");
          console.trace("### At this location ###");
          conn.database = X.options.datasource.databases[0]; // XXX FIXME this has to come from req.session.passport.user.organization
        }

        this.query(query, conn, complete);
        return true;
      }
    };

  //
  // Set up listener for postgres events on the nodext channel
  //
  /*
    do $$
      var payload = {action: "email", content: {
        from: "no-reply@xtuple.com",
        to: "shackbarth@xtuple.com",
        subject: "test subject",
        text: "test body"
      }};
      plv8.execute("select pg_notify($1, $2);", ['nodext', JSON.stringify(payload)]);
    $$ language plv8;
  */
  var setupPgListeners = function (databases, eventHandlers) {
    var afterAction = function () {
      // do nothing.
      console.log("action taken", arguments);
    };
    _.each(databases, function (database) {
      var creds = DataSource.getAdminCredentials(database);
      pg.connect(creds, function (err, client, done) {
        if (err) {
          return console.error('error fetching client from pool', err);
        }
        client.on('notification', function (msg) {
          var payload = JSON.parse(msg.payload);

          // the event handlers get passed in by the caller. Just run the
          // event handler that corresponds to the action postgres is
          // requesting.
          eventHandlers[payload.action](payload.content, afterAction);
        });
        client.query("LISTEN nodext");
        X.log("Listening for postgres notifications on the nodext channel on ", database);
      });
    });
  };

  XT.dataSource = DataSource;

  module.exports = {
    api: DataSource,
    dataSource: XT.dataSource,
    setupPgListeners: setupPgListeners
  };

}());
