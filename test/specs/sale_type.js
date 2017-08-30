/*jshint indent:2, curly:true, eqeqeq:true, immed:true, latedef:true,
newcap:true, noarg:true, regexp:true, undef:true, strict:true, trailing:true,
white:true*/
/*global XV:true, XT:true, _:true, console:true, XM:true, Backbone:true, require:true, assert:true,
setTimeout:true, before:true, clearTimeout:true, exports:true, it:true, describe:true, beforeEach:true */

(function () {
  "use strict";

  var async = require("async"),
    _ = require("underscore"),
    smoke = require("../lib/smoke"),
    common = require("../lib/common"),
    assert = require("chai").assert;

  /**
    Sale Type
    @class
    @alias SaleType
    @property {String} code
    @property {String} description
    @property {SalesEmailProfile} emailProfile
    @property {SaleTypeCharacteristicCollection} characteristics
    @property {SalesTypeWorkflow} workflow
    @property {String} defaultHoldType
  */
  var spec = {
    recordType: "XM.SaleType",
    collectionType: "XM.SaleTypeCollection",
    cacheName: null,
    listKind: "XV.SaleTypeList",
    instanceOf: "XM.Document",
		/**
      @member -
      @memberof SaleType
      @description Sale Types are lockable
    */
    isLockable: true,
		/**
      @member -
      @memberof SaleType
      @description The ID attribute is "code", which will be automatically uppercased.
    */
    idAttribute: "code",
    enforceUpperKey: true,
    attributes: ["code", "description", "characteristics",
      "emailProfile", "defaultHoldType"],
    /**
      @member -
      @memberof SaleType
      @description Used in the sales module
    */
    extensions: ["sales"],
    /**
      @member -
      @memberof SaleType
      @description Sale Types can be read by anyone and can be created and updated
        by users with the "MaintainSaleTypes" privilege.
    */
    privileges: {
      createUpdate: "MaintainSaleTypes",
      read: true
    },
    createHash: {
      code: "TESTSALE" + Math.random(),
      description: "Test Sale Type"
    },
    updatableField: "description"
  };

  var additionalTests = function () {
    /**
      @member -
      @memberof SaleType.prototype
      @description Sale Types used in a sales order cannot be deleted
     */
    it("Sale Types used in a sales order cannot be deleted", function () {
    });

    describe("Sale type characteristics", function () {
      /**
        @member -
        @memberof SaleType.prototype
        @description Characteristics can be associated with sale types.
      */
      it("is a SaleTypeCharacteristic", function () {
        var model;

        assert.isFunction(XM.SaleTypeCharacteristic);
        model = new XM.SaleTypeCharacteristic();
        assert.isTrue(model instanceof XM.CharacteristicAssignment);
      });
      /**
        @member -
        @memberof SaleType.prototype
        @description The available characteristic types are shared with sales orders
      */
      it.skip("uses isSalesOrders as its context attribute", function () {
      });
    });
  };

  exports.spec = spec;
  exports.additionalTests = additionalTests;

}());

