/*jshint node:true, indent:2, curly:false, eqeqeq:true, immed:true, latedef:true, newcap:true, noarg:true,
regexp:true, undef:true, strict:true, trailing:true, white:true */
/*global _:true */


/**
  The Qt updater had logic baked into it to deal specially with .mql, .ui, .xml, and .js
  database files. We replicate that logic here.
*/

(function () {
  "use strict";

  var path = require('path');

  var convertFromMetasql = function (content, filename, defaultSchema, script) {
    var lines = content.split("\n"),
      schema = defaultSchema ? "'" + defaultSchema + "'" : "NULL",
      script = script || {},
      group,
      i = 2,
      name,
      notes = "",
      grade = script.grade ? script.grade : 0,
      hasBOM = (lines[0].charCodeAt(0) === 0xFEFF || lines[0].charCodeAt(0) === 0xFFFE) ;


    if (lines[0].indexOf("-- Group:") !== (hasBOM ? 1 : 0) ||
        lines[1].indexOf("-- Name:") !== 0 ||
        lines[2].indexOf("-- Notes:") !== 0) {
      throw new Error("Improperly formatted metasql: " + filename);
    }
    group = lines[0].substring("-- Group:".length + (hasBOM ? 1 : 0)).trim();
    name = lines[1].substring("-- Name:".length).trim();
    while (lines[i].indexOf("--") === 0) {
      notes = notes + lines[i].substring(2) + "\n";
      i++;
    }
    notes = notes.substring(" Notes:".length);

    return "select saveExtensionObject('metasql'," + "'" + group + "'," + "'" + name + "'," + grade +
                ",$content$" + content + "$content$," + "$notes$" + notes + "$notes$,TRUE," +
                schema + ");";
  };

  var convertFromReport = function (content, filename, defaultSchema, script) {
    var lines = content.split("\n"),
      schema = defaultSchema ? "'" + defaultSchema + "'" : "NULL",
      script = script || {},
      name,
      grade = script.grade ? script.grade.toString() : "0",
      description;

    if (lines[3].indexOf(" <name>") !== 0 ||
        lines[4].indexOf(" <description>") !== 0) {
      throw new Error("Improperly formatted report");
    }
    name = lines[3].substring(" <name>".length).trim();
    name = name.substring(0, name.indexOf("<"));
    description = lines[4].substring(" <description>".length).trim();
    description = description.substring(0, description.indexOf("<"));
    if (lines[5].indexOf("grade") >= 0) {
      grade = lines[5].substring(" <grade>".length).trim();
      grade = grade.substring(0, grade.indexOf("<"));
    }

    return "select saveExtensionObject('report', NULL,'" + name + "'," + parseInt(grade) +
                ",$content$" + content + "$content$," + "$description$" + description + "$description$,TRUE," +
                schema + ");";

  };

  var convertFromScript = function (content, filename, defaultSchema, script) {
    var name = path.basename(filename, '.js'),
      schema = defaultSchema ? "'" + defaultSchema + "'" : "NULL",
      script = script || {},
      order = script.order ? script.order : 0;

    return "select saveExtensionObject('script'," + "NULL,'" + name + "'," + order +
                ",$content$" + content + "$content$,'',TRUE," +
                schema + ");";
  };

  var convertFromUiform = function (content, filename, defaultSchema, script) {
    var name = path.basename(filename, '.ui'),
      schema = defaultSchema ? "'" + defaultSchema + "'" : "NULL",
      script = script || {},
      order = script.order ? script.order : 0;
    return "select saveExtensionObject('uiform'," + "NULL,'" + name + "'," + order + 
                ",$content$" + content + "$content$,'',TRUE," +
                schema + ");";
  };

  // handier than a switch statement
  exports.conversionMap = {
    mql: convertFromMetasql,
    xml: convertFromReport,
    js: convertFromScript,
    ui: convertFromUiform,
    sql: function (content) {
      // no op
      return content;
    }
  };
}());
