/*jshint node:true, indent:2, curly:false, eqeqeq:true, immed:true, latedef:true, newcap:true,
noarg:true, regexp:true, undef:true, strict:true, trailing:true, white:true */
/*global _:true, XT:true, X:true, plv8:true, WARNING:true */

(function () {
  "use strict";

  /**
   * Format a complex REST API query structure into an xTuple's datasource database query.
   *
   * This is a helper function that reformats the query structure from a REST API
   * query in to our XT.Rest query format. This function should be used by reformat
   * any REST API client queries.
   *
   * Example usage:
   *   var myQueryRequest = {
   *     "query": {
   *       "city":{"EQUALS":"Norfolk"}
   *     },
   *     "orderby": {
   *       {"ASC": "line1"},
   *       {"DESC": "line2"}
   *     }
   *   },
   *   payload = {
   *     nameSpace: "XM",
   *     type: "Address"
   *   };
   *   payload.query = XM.Model.restQueryFormat("XM.Address", "/db-name-here/api/v1alpha1/resources/address", myQueryRequest);
   *   if (payload.query) {
   *     return routes.queryDatabase("get", payload, session, callback);
   *   }
   *
   * @param {String} recordType: The ORM recordType to query.
   * @param {String} requestString: Optional. The original request's query string.
   *                                This could be the URL path requested or the
   *                                POSTed request query body for service dipatch calls.
   *                                It is only used to log errors.
   * @param {Object} requestQuery: The REST API requested query object.
   *
   * @returns {Object} The formated query ready to be passed to the datasource.
   */
  function restQueryFormat (recordType, requestString, requestQuery) {
    try {
      var order = {},
          param = {},
          query = {},
          nameSpace = recordType.split(".")[0],
          type = recordType.split(".")[1],
          schema,
          validColNamePattern = new RegExp("^[a-zA-Z_][a-zA-Z0-9_]*$"),
          mapOperator = function (op) {
            // Convert REST API operator format to datasource format.
            var operators = {
                  value: {
                    ANY:          "ANY",
                    NOT_ANY:      "NOT ANY",
                    EQUALS:       "=",
                    NOT_EQUALS:   "!=",
                    LESS_THAN:    "<",
                    AT_MOST:      "<=",
                    GREATER_THAN: ">",
                    AT_LEAST:     ">=",
                    MATCHES:      "MATCHES",
                    BEGINS_WITH:  "BEGINS_WITH"
                  }
                };

            if (operators.value[op]) {
              return operators.value[op];
            } else {
              throw new Error();
            }
          },
          validateColumn = function (column) {
            // Make sure the column name is a valid PostgreSQL string.
            // Make sure the column is in the schema for this recordType.
            var valid = false,
              parentColumn = column.split(".")[0];

            if (validColNamePattern.test(column)) {
              for (var c = 0; c < schema.columns.length; c++) {
                // TODO: Only checking the recordType parameter columns, not any
                // toOne/toMany child columns. e.g. "[address.city]"
                if (schema.columns[c].name === parentColumn) {
                  valid = true;
                }
              }
            }

            return valid;
          },
          validateValue = function (value) {            
            // The value should be an array, string, boolean or numeric.
            if (Array.isArray(value)) {
              return value;
            }
            switch (typeof value) {
              case "boolean":
              case "number":
              case "string":
                return value;
              default:
                throw new Error();
            }
          };

      requestQuery = requestQuery || {};

      if (typeof plv8 !== "undefined") {
        // Get the schema in plv8.
        schema = XT.Session.schema(nameSpace.decamelize(), type.decamelize())[type];
      } else {
        // Get the schema in node-datasource.
        schema = XT.session.schemas.XM.attributes[type];
      }

      /* Convert from REST API query to XM.Model.query structure. */
      if (requestQuery) {
        if (requestQuery.query) {
          query.parameters = [];
          for (var column in requestQuery.query) {
            if (validateColumn(column)) {
              for (var op in requestQuery.query[column]) {
                param = {};
                param.attribute = column;
                param.operator = mapOperator(op);
                param.value = validateValue(requestQuery.query[column][op]);
                query.parameters.push(param);
              }
            } else {
              throw new Error();
            }
          }
        }

        /* Convert from REST API free text query to XM.Model.query structure. */
        if (recordType && requestQuery.q) {
          /* Add string columns to search query. */
          param = {
            "attribute": []
          };

          // TODO: Test that schema variable in plv8 works here.
          for (var c = 0; c < schema.columns.length; c++) {
            if (schema.columns[c].category === "S") {
              param.attribute.push(schema.columns[c].name);
            }
          }

          if (param.attribute.length) {
            /* Add all string columns to attribute query. */
            query.parameters = query.parameters || [];
            param.operator = "MATCHES";

            /* Replace any spaces with regex ".*" so multi-word search works on similar strings. */
            param.value = requestQuery.q.replace(" ", ".*");
            query.parameters.push(param);
          }
        }

        /* Convert from REST API orderBy query to XM.Model.query structure. */
        if (requestQuery.orderby || requestQuery.orderBy) {
          requestQuery.orderBy = requestQuery.orderby || requestQuery.orderBy;
          delete requestQuery.orderby;
          query.orderBy = [];
          for (var col in requestQuery.orderBy) {
            if (validateColumn(col)) {
              order = {};
              order.attribute = col;
              if (requestQuery.orderBy[col] === "DESC") {
                order.descending = true;
              } else {
                order.descending = false;
              }
              query.orderBy.push(order);
            } else {
              throw new Error();
            }
          }
        }

        /* Convert from REST API rowLimit query to XM.Model.query structure. */
        if (requestQuery.rowlimit || requestQuery.rowLimit) {
          requestQuery.rowLimit = +requestQuery.rowlimit || +requestQuery.rowLimit;
          delete requestQuery.rowlimit;
          query.rowLimit = requestQuery.rowLimit;
        } else {
          query.rowLimit = 100;
        }

        /* Convert from REST API maxResults query to XM.Model.query rowLimit structure. */
        if (requestQuery.maxresults || requestQuery.maxResults) {
          requestQuery.maxResults = +requestQuery.maxresults || +requestQuery.maxResults;
          delete requestQuery.maxresults;
          query.rowLimit = requestQuery.maxResults;
        }

        /* Convert from REST API pageToken query to XM.Model.query rowOffset structure. */
        if (requestQuery.pagetoken || requestQuery.pageToken) {
          requestQuery.pageToken = +requestQuery.pagetoken || +requestQuery.pageToken;
          delete requestQuery.pagetoken;
          if (query.rowLimit) {
            query.rowOffset = (requestQuery.pageToken || 0) * (query.rowLimit);
          } else {
            query.rowOffset = (requestQuery.pageToken || 0);
          }
        }

        /* Convert from REST API count query to XM.Model.query structure. */
        if (requestQuery.count || (requestQuery.hasOwnProperty("count") && requestQuery.count !== false)) {
          query.count = true;
        }
      }

      return query;
    } catch (err) {
      // Log this error to the console. The restRouter will send a 400 error back to the client.
      if (typeof plv8 !== "undefined") {
        plv8.elog(WARNING, "Bad REST query requestString: ", requestString,
                           "\nQuery string:\n", JSON.stringify(requestQuery, null, 2),
                           "\nStack ", err.stack);
      } else {
        // Log this error to the console. The restRouter will send a 400 error back to the client.
        X.err("Bad REST query requestString: ", requestString,
              "\nQuery string:\n", JSON.stringify(requestQuery, null, 2),
              "\nStack ", err.stack);
      }

      return false;
    }
  }

  module.exports = restQueryFormat;
})();
