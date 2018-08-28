/*jshint node:true, indent:2, curly:false, eqeqeq:true, immed:true, latedef:true, newcap:true, noarg:true,
regexp:true, undef:true, strict:true, trailing:true, white:true */
/*global _:true */

(function () {
  "use strict";

  var exec = require('child_process').exec,
    fs = require('fs'),
    path = require('path');

/**
  Exec psql to actually execute the query
*/
  var sendToDatabase = function (query, credsClone, options, callback) {
    var filename = path.join(__dirname, "../../output/build_" + credsClone.database + ".sql");
    if (!fs.existsSync(path.join(__dirname, "../../output"))) {
      fs.mkdirSync(path.join(__dirname, "../../output"));
    }
    fs.writeFile(filename, query, function (err) {
      if (err) {
        console.error("Cannot write query to file");
        callback(err);
        return;
      }
      var psqlCommand = 'psql -d ' + credsClone.database +
        ' -U ' + credsClone.username +
        ' -h ' + credsClone.hostname +
        ' -p ' + credsClone.port +
        ' -f ' + filename +
        ' --single-transaction 2> ' + filename + '.log';

      /**
       * http://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback
       * "maxBuffer specifies the largest amount of data allowed on stdout or
       * stderr - if this value is exceeded then the child process is killed."
       */
      exec(psqlCommand, {maxBuffer: 40000 * 1024 /* 200x default */}, function (err, stdout, stderr) {
        if (err) {
          console.error("Cannot install file ", filename);
          console.error("See errors in ", filename + ".log");
          exec('tail -20 ' + filename + ".log", function (logerr, logstdout, logstderr) {
            var logHeader = "\n################################################################################\n" +
                            "# ERROR: psql stderr OUTPUT LAST 20 LINES OF: " + filename + ".log\n" +
                            "################################################################################\n\n",
                logfooter = "\n################################################################################\n" +
                            "# END OF psql stderr LOG OUTPUT ################################################\n" +
                            "################################################################################\n\n";
            console.log(logHeader, logstdout, logfooter);
            callback(err);
          });
          return;
        }
        if (options.keepSql) {
          // do not delete the temp query file
          console.log("SQL file kept as ", filename);
          callback();
        } else {
          fs.unlink(filename, function (err) {
            if (err) {
              console.error("Cannot delete written query file");
              callback(err);
            }
            callback();
          });
        }
      });
    });
  };
  exports.sendToDatabase = sendToDatabase;
}());
