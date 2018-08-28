var _       = require("underscore"),
    assert  = require("chai").assert;

(function () {
  "use strict";

  describe('document assignment triggers test', function () {

    var loginData  = require("../../lib/login_data.js").data,
        datasource = require("../../../node-datasource/lib/ext/datasource").dataSource,
        config     = require("../../../node-datasource/config.js"),
        config     = require("../../../node-datasource/config.js"),
        creds      = _.extend({}, config.databaseServer, {database: loginData.org}),
        insertImageSql = "INSERT INTO image (image_name, image_descrip, image_data) " +
                         "VALUES ('testImage', 'A Test Image', 'This is not image data') " +
                         "RETURNING image_id;",
        imageID,
        insertImageAss = "INSERT INTO imageass (imageass_source_id, imageass_source, imageass_image_id, imageass_purpose) " +
                         "VALUES ((SELECT item_id FROM item WHERE item_number = 'BTRUCK1'), 'I', $1, 'I');",
        deleteSql      = "DELETE FROM image WHERE image_id = $1;",
        checkSql       = "SELECT count(*) as counter FROM imageass WHERE imageass_image_id = $1;",

        insertDocSql = "INSERT INTO file (file_title, file_descrip, file_stream) " +
                         "VALUES ('testDocument', 'A Test Document', 'This is not document data'::bytea) " +
                         "RETURNING file_id;",
        fileID,
        insertDocAss = "INSERT INTO docass (docass_source_id, docass_source_type, docass_target_id, docass_target_type, docass_purpose) " +
                         "VALUES ((SELECT item_id FROM item WHERE item_number = 'BTRUCK1'), 'I', $1, 'FILE', 'S');",
        deleteDocSql      = "DELETE FROM file WHERE file_id = $1;",
        checkDocSql       = "SELECT count(*) as counter FROM docass WHERE docass_target_type = 'FILE' AND docass_target_id = $1;";

    it("insert test image", function (done) {
      var options = _.extend({}, creds);
      datasource.query(insertImageSql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, 'expected one image to be created');
        imageID = res.rows[0].image_id;
        assert.isTrue(imageID > 0, 'expected a real image ID');
        done();
      });
    });

    it("insert test image assignment", function (done) {
      var options = _.extend({}, creds,
                            { parameters: [ imageID ]});
      datasource.query(insertImageAss, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, 'expected one assignment to be created');
        done();
      });
    });

    it("delete test image and check assignment", function (done) {
      var options = _.extend({}, creds,
                            { parameters: [ imageID ]}),
          deli = function () { 
            /** delete the image **/
            datasource.query(deleteSql, options, function (err, res) {
              assert.isNull(err);
              chki();
            });
          },
          chki = function () {
            /** and check the associated assignment no longer exists **/
            datasource.query(checkSql, options, function (err, res) {
              assert.isNull(err);
              assert.equal(res.rows[0].counter, 0, 'expected no assignment records to remain');
              if (_.isFunction(done)) { done(); }
            });
          };

        deli();
    });

    it("insert test document", function (done) {
      var options = _.extend({}, creds);
      datasource.query(insertDocSql, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, 'expected one document to be created');
        fileID = res.rows[0].file_id;
        assert.isTrue(fileID > 0, 'expected a real file id');
        done();
      });
    });

    it("insert test document assignment", function (done) {
      var options = _.extend({}, creds,
                            { parameters: [ fileID ]});
      datasource.query(insertDocAss, options, function (err, res) {
        assert.isNull(err);
        assert.equal(res.rowCount, 1, 'expected one document assignment to be created');
        done();
      });
    });

    it("delete test file and check assignment", function (done) {
      var options = _.extend({}, creds,
                            { parameters: [ fileID ]}),
          delf = function () { 
            /** delete the file **/
            datasource.query(deleteDocSql, options, function (err, res) {
              assert.isNull(err);
              chkf();
            });
          },
          chkf = function () {
            /** and check the associated assignment no longer exists **/
            datasource.query(checkDocSql, options, function (err, res) {
              assert.isNull(err);
              assert.equal(res.rows[0].counter, 0, 'expected no document assignment records to remain');
              if (_.isFunction(done)) { done(); }
            });
          };

        delf();
    });

  });
})();
