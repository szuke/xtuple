/*jshint bitwise:true, indent:2, curly:true, eqeqeq:true, immed:true,
latedef:true, newcap:true, noarg:true, regexp:true, undef:true,
trailing:true, white:true, strict:false*/
/*global XT:true, XM:true, XV:true, enyo:true*/

(function () {

  XT.extensions.project.initListRelationsEditorBoxes = function () {
    var extensions;

    // ..........................................................
    // PROJECT
    //

    enyo.kind({
      name: "XV.ProjectTaskEditor",
      kind: "XV.RelationsEditor",
      components: [
        {kind: "XV.ScrollableGroupbox", name: "mainGroup", fit: true,
          classes: "in-panel", components: [
          {kind: "XV.InputWidget", attr: "number"},
          {kind: "XV.InputWidget", attr: "name"},
          {kind: "XV.ProjectStatusPicker", attr: "status"},
          {kind: "XV.PriorityPicker", attr: "priority"},
          {kind: "XV.PercentWidget", attr: "percentComplete"},
          {kind: "onyx.GroupboxHeader", content: "_schedule".loc()},
          {kind: "XV.DateWidget", attr: "dueDate"},
          {kind: "XV.DateWidget", attr: "startDate"},
          {kind: "XV.DateWidget", attr: "assignDate"},
          {kind: "XV.DateWidget", attr: "completeDate"},
          {kind: "onyx.GroupboxHeader", content: "_hours".loc()},
          {kind: "XV.QuantityWidget", attr: "budgetedHours",
           label: "_budgeted".loc()},
          {kind: "XV.QuantityWidget", attr: "actualHours",
           label: "_actual".loc()},
          {kind: "onyx.GroupboxHeader", content: "_expenses".loc()},
          {kind: "XV.MoneyWidget", attr: {localValue: "budgetedExpenses"},
           label: "_budgeted".loc(), currencyShowing: false},
          {kind: "XV.MoneyWidget", attr: {localValue: "actualExpenses"},
           label: "_actual".loc(), currencyShowing: false},
          {kind: "onyx.GroupboxHeader", content: "_userAccounts".loc()},
          {kind: "XV.UserAccountWidget", attr: "owner"},
          {kind: "XV.UserAccountWidget", attr: "assignedTo"},
          {kind: "XV.TaskCharacteristicsWidget", attr: "characteristics"},
          {kind: "onyx.GroupboxHeader", content: "_notes".loc()},
          {kind: "XV.TextArea", attr: "notes", fit: true}
        ]}
      ]
    });

    enyo.kind({
      name: "XV.ProjectTasksBox",
      kind: "XV.ListRelationsEditorBox",
      classes: "xv-list-relations-box",
      title: "_tasks".loc(),
      editor: "XV.ProjectTaskEditor",
      parentKey: "project",
      listRelations: "XV.ProjectTaskListRelations",
      fitButtons: false
    });


    //
    // TASK RESOURCES
    //
    enyo.kind({
      name: "XV.TaskResourcesEditor",
      kind: "XV.RelationsEditor",
      components: [
        {kind: "XV.ScrollableGroupbox", name: "mainGroup", fit: true,
          classes: "in-panel", components: [
          {kind: "XV.ResourcePicker", attr: "resource"},
          // TODO: use {kind: "XV.ResourceWidget", attr: "resource"},
          {kind: "XV.PercentWidget", attr: "percent"}
        ]}
      ]
    });

    enyo.kind({
      name: "XV.TaskResourcesBox",
      kind: "XV.ListRelationsEditorBox",
      title: "_resources".loc(),
      editor: "XV.TaskResourcesEditor",
      parentKey: "task", // XXX projectTask?
      listRelations: "XV.TaskResourceListRelations",
      fitButtons: false
    });

  };
}());
