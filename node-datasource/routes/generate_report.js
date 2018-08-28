/*jshint node:true, indent:2, curly:false, eqeqeq:true, immed:true, latedef:true, newcap:true, noarg:true,
regexp:true, undef:true, strict:true, trailing:true, white:true */
/*global X:true, XT:true, XM:true, SYS:true */

(function () {
  "use strict";

  //
  // DEPENDENCIES
  //

  var _ = require("underscore"),
    async = require("async"),
    fs = require("fs"),
    path = require("path"),
    child_process = require("child_process"),
    queryForData = require("./export").queryForData;

  XT.transformFunctions = {};

  /**
    Generates a report using fluentReports

    @property req.query.nameSpace
    @property req.query.type
    @property req.query.id
    @property req.query.action

    Sample URL:
    https://localhost:8443/dev/generate-report?nameSpace=XM&type=Invoice&id=60000&action=print

   */
  var generateReport = function (req, res) {
    //
    // VARIABLES THAT SPAN MULTIPLE STEPS
    //
    var reportDefinition,
      rawData = {}, // raw data object
      reportData, // array with report data
      username = req.session.passport.user.id,
      databaseName = req.session.passport.user.organization,
      // TODO: introduce pseudorandomness (maybe a timestamp) to avoid collisions
      reportName = req.query.type.toLowerCase() + (req.query.id || "") + (req.query.printQty || "") + ".pdf",
      auxilliaryInfo = req.query.auxilliaryInfo,
      printer = req.query.printer,
      printQty = req.query.printQty || 1,
      workingDir = path.join(__dirname, "../temp", databaseName),
      reportPath = path.join(workingDir, reportName),
      imageFilenameMap = {},
      translations,
      id;

    //
    // WAYS TO RETURN TO THE USER
    //

    /**
      Stream the pdf to the browser (on a separate tab, presumably)
     */
    var responseDisplay = function (res, data, done) {
      res.header("Content-Type", "application/pdf");

      res.send(data);
      done();
    };

    /**
      Stream the pdf to the user as a download
     */
    var responseDownload = function (res, data, done) {
      res.header("Content-Type", "application/pdf");
      res.attachment(reportPath);
      res.send(data);
      done();
    };

    /**
      Send an email
     */
    var responseEmail = function (res, data, done) {

      var emailProfile;
      var fetchEmailProfile = function (done) {
        var emailProfileId = reportData[0].customer.emailProfile,
          statusChanged = function (model, status, options) {
            if (status === XM.Model.READY_CLEAN) {
              emailProfile.off("statusChange", statusChanged);
              done();
            }
          };
        if (!emailProfileId) {
          done({isError: true, message: "Error: no email profile associated with customer"});
          return;
        }
        emailProfile = new SYS.CustomerEmailProfile();
        emailProfile.on("statusChange", statusChanged);
        emailProfile.fetch({
          id: emailProfileId,
          database: databaseName,
          username: username
        });
      };

      var sendEmail = function (done) {
        var formattedContent = {},
          callback = function (error, response) {
            if (error) {
              X.log("Email error", error);
              res.send({isError: true, message: "Error emailing"});
              done();
            } else {
              res.send({message: "Email success"});
              done();
            }
          };

        // populate the template
        _.each(emailProfile.attributes, function (value, key, list) {
          if (typeof value === 'string') {
            formattedContent[key] = XT.String.formatBraces(reportData[0], value);
          }
        });

        formattedContent.text = formattedContent.body;
        formattedContent.attachments = [{fileName: reportPath, contents: data, contentType: "application/pdf"}];

        X.smtpTransport.sendMail(formattedContent, callback);
      };

      async.series([
        fetchEmailProfile,
        sendEmail
      ], done);
    };

    // Convenience hash to avoid if-else
    var responseFunctions = {
      display: responseDisplay,
      download: responseDownload,
      email: responseEmail
    };

    //
    // STEPS TO PERFORM ROUTE
    //

    /**
      Make a directory node-datasource/temp if none exists
     */
    var createTempDir = function (done) {
      fs.exists("./temp", function (exists) {
        if (exists) {
          done();
        } else {
          fs.mkdir("./temp", done);
        }
      });
    };

    /**
      Make a directory node-datasource/temp/orgname if none exists
     */
    var createTempOrgDir = function (done) {
      fs.exists("./temp/" + databaseName, function (exists) {
        if (exists) {
          done();
        } else {
          fs.mkdir("./temp/" + databaseName, done);
        }
      });
    };

    /**
      Dispatch the report however the client wants it
        -Email
        -Stream download
        -Display to browser
    */
    var sendReport = function (done) {
      fs.readFile(reportPath, function (err, data) {
        if (err) {
          res.send({isError: true, error: err});
          return;
        }

        // Send the appropriate response back the client
        responseFunctions[req.query.action || "display"](res, data, done);
      });
    };

    /**
     TODO
     Do we want to clean these all up every time? Do we want to cache them? Do we want to worry
     about files getting left there if the route crashes before cleanup?
     */
    var cleanUpFiles = function (done) {
      // TODO
      done();
    };

    var execOpenRPT = function (done) {
      var args = [
        "-display", ":17",
        "-close",
        "-h", X.options.databaseServer.hostname,
        "-p", X.options.databaseServer.port,
        "-d", req.session.passport.user.organization,
        "-U", username,
        "-loadfromdb=" + req.query.type,
        "-numCopies=" + printQty
      ];

      if (printer) {
        args.push(
          "-printerName=" + printer,
          "-autoprint"
        );
      } else {
        args.push(
          "-pdf",
          "-outpdf=" + reportPath
        );
      }

      if (_.isArray(req.query.param)) {
        _.each(req.query.param, function (param) {
          args.push("-param=" + param);
        });
      } else {
        args.push("-param=" + req.query.param);
      }
      
      child_process.execFile("rptrender", args, null, function (error, stdout) {
        if (error) {
          res.send({isError: true, message: "rptrender error: " + error});
        } else if (printer) {
          res.send({message: "Print Success!"});
        }
        // Continue on to the next func in prinAry (sendReport).
        done();
      });
    };

    //
    // Actually perform the operations, one at a time
    //

    // Support rendering through openRPT via the following API:
    // https://localhost/demo_dev/generate-report?nameSpace=ORPT&type=AddressesMasterList
    // https://localhost/demo_dev/generate-report?nameSpace=ORPT&type=AROpenItems&param=startDate:date=%272007-01-01%27
    // https://localhost:8443/dev/generate-report?nameSpace=ORPT&type=Invoice&param=invchead_id::integer=128&param=showcosts::boolean=true
    var printAry = (printer && req.query.action === "print") ? [execOpenRPT] : [ // If the printer is defined, call `execOpenRPT` only 
      createTempDir,
      createTempOrgDir,
      execOpenRPT,
      sendReport,
      cleanUpFiles
    ];

    async.series(printAry, function (err, results) {
      if (err) {
        res.send({Error: results});
      }
    });
  };

  exports.generateReport = generateReport;

}());
