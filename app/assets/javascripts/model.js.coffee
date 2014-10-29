# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require entity_reports

$ ->

    console.log "setting up models"

    window.models = {
      "entity"  : createModel("entity", "entities"),
      "group"   : createModel("group", "groups"),
      "property": createModel("property", "properties"), 
      "epr"     : createModel("epr", "entity_property_relationships"), 
      "gpr"     : createModel("gpr", "group_property_relationships"), 
      "egr"     : createModel("egr", "entity_group_relationships") 
      "role"    : createModel("role", "roles"), 
      "user"    : createModel("user", "users")
    }

    #additional parameters for relationships
    #these relationships need to be aware of which of their associations are selected
    window.models["egr"].selected_entities = window.models["entity"].selected
    window.models["epr"].selected_entities = window.models["entity"].selected
    window.models["epr"].view_id = window.models["role"].view_id
    window.models["epr"].selected_egrs = window.models["egr"].selected
    window.models["gpr"].selected_groups = window.models["group"].selected
    window.models["role"].view_id = $("input#rr").val()

    for modelName, model of window.models
      model.fields = createModelFields(modelName)

    #if a table header is clicked, send a query request
    #for the model that will sort by that column
    $('div.list').on 'click', "th a", (e) ->
        #get parameter data from header element
        _data = $(this).data()

        #set the model's sorting direction and column from the element data
        window.models[_data.model].direction = _data.direction
        window.models[_data.model].column = _data.column

        #prepare and send the query
        query(_data.model)
        false

    #Actions/Settings for collapsing the 'Create New' panel
    $("div.collapsible.panel-heading").on "click", (e) ->
        e.preventDefault()

    #On list element click, highlight it and make it the selected item
    #Also list any associated egrs
    #TODO: update list item elements in the view
    $("body").on "click", '.table tr.list-item', (e) ->
        _data = $(this).data()
        toggleSelect(_data.model, _data.id, e.ctrlKey || e.metaKey)
        # toggleEntitySelect(this.id, e.ctrlKey || e.metaKey)

    #When the clear button is clicked
    #TODO: update action buttons to have classes: btn #{model} #{type} selected 
    $("body").on "click", "div.btn.clear.selection", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            #TODO: add model attribute to action buttons
            console.log "clear btn clicked"
            clearSelected($(this).attr("model"))

    #When the delete button is clicked
    $("body").on "click", "div.btn.delete.selection", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            deleteRequest( $(this).attr("model") )
            console.log "delete btn clicked"

    $("body").on "click", "div.btn.view.selection", (e) ->
        e.preventDefault()
        unless $(this).hasClass "disabled"
          modelName = $(this).attr("model")
          model = window.models[modelName]
          if model == null
            return false
          Turbolinks.visit(model.controller+"/" + model.selected[0])

    #Every character change in Search field, submit query
    #TODO: update search element for model data accessors
    $("body").on "input", "input.search", (e) ->
        modelName = $(this).attr("model")
        console.log( "search_model: '"+modelName+"' -- search_string: '" + $(this).val() + "'")
        window.models[modelName].search = $(this).val()
        query(modelName)
        return false

    #TODO: Remove list item delete button
    # $("body").on "click", "span.entity.delete", (e) ->
    #     deleteRequest(this.id)
    #     console.log "delete clicked"

    #TODO: delete confirm attribute update
    $("body").on "click", "button.delete.confirm", (e) ->
        modelName = $(this).attr("model")
        console.log("confirm delete: " + modelName)
        confirmDelete(modelName)

    #TODO: on key input for name field, if space, replace with underscore
    #$("body").on "keyup", "input.property.name", (e) ->
    #           if e.keyCode == 32 #spacebar pressed
    #             # e.preventDefault()
    #             # $(this).val($(this).val() + "_")
    #             $(this).val($(this).val().replace(" ", "_"))
    #             NewPropertyValidation(this.id)
    #             # return false


    #TODO: Register form validators for the model's form
    $("input.form-model").each ->
      modelName = $(this).attr("model")
      console.log("model: " + modelName)
      fields = window.models[modelName].fields
      console.log("fields: ")
      console.log(fields)
      formValidation(modelName)
      for fieldName, fieldGroup of fields
        if fields.hasOwnProperty(fieldName)
          console.log("fieldName")
          console.log(fieldName)
          console.log("fieldGroup")
          console.log(fieldGroup)
          $("body").on "input", fieldGroup.field, (e) ->
            console.log( $(this).val() )
            formValidation(modelName)

    #Roles Select
    $("select.roles").select2({
      placeholder: "View As...",
    })

    $("select.roles").on "change", (e) ->
      console.log("role: " + $(this).val())
      window.models["role"].view_id = $(this).val()
      query("epr")

    $("select.")


createModel = (name, controller) ->
  model = {
    exists: $("body").hasClass(name),
    model: name,
    controller: controller,
    selected: [],
    page: "1",
    direction: "desc", #for sorting
    column: "updated_at", #for sorting
    search: "" 
  }
  return model
#end

#TODO: update
deleteRequest = (modelName) ->
  #log which model
  console.log ("deleting " + modelName)

  model = window.models[modelName]

  if model == null
    return false

  params = $.param(model)

  # $.post( model.controller + "/delete_request?" + params )
  $.post( "/delete_request?" + params )

#TODO: do this
confirmDelete = (modelName) ->

  #log which model
  console.log ("deleting " + modelName)

  model = window.models[modelName]

  if model == null
    return false

  params = $.param(model)
  $.post( model.controller + "/confirm_delete?" + params )
#end

#takes the model object, paramifies it and queries on it
query = (modelName) ->
  #log which model
  console.log ("querying " + modelName)

  model = window.models[modelName]

  if model == null
    return false

  #put the model attributes into request parameters
  params = $.param(model)

  #send the query request
  #TODO: Query might be a global controller action which would simplify the response
  $.get model.controller + "?" + params
  # $.get "query?" + params
#end

#Ensure ajaxified pagination buttons on any additions to list
#TODO: look at how to modularize
entityPagination = () ->
    #Ajaxify List Page changes
    $("div#entities").on "click", '.pagination a', (e) ->
        window.entities_page = getParameterByName( "entities_page", this.href ) || "1"
        entityQuery()
        false
window.entityPagination = entityPagination

#TODO: verify
toggleSelect = (model, id, multiSelect) ->
    index = $.inArray(id, window.models[model].selected)
    #if the clicked entity is already selected
    if index > -1
        #if the there is already one other entity selected and the user isn't
        #using multi-select (ctrl or meta key)
        if window.models[model].selected.length > 1 && !multiSelect
            #then clear what is selected
            clearSelected(model)
            #push this entity into the selected list and make its appearance selected
            $("tr#"+id+"."+model).addClass "selected"
            #TODO: CSS for class 'selected' for selected row items
            window.models[model].selected.push(id)
        #otherwise, just add this entity to the list of selected
        else
            $("tr#"+id+"."+model).removeClass "selected"
            window.models[model].selected.splice(index, 1)
    #if the user is enabling multiselect
    else if multiSelect
        #select the entity
        $("tr#"+id+"."+model).addClass "selected"
        window.models[model].selected.push(id)
    else
        #otherwise, clear what's selected and add it
        clearSelected(model)
        $("tr#"+id+"."+model).addClass "selected"
        window.models[model].selected.push(id)
    validateSelection(model)
window.toggleSelect = toggleSelect

#TODO: verify
clearSelected = (model) ->
    $("tr.selected."+model).removeClass "selected"
    window.models[model].selected = []
    validateActionButtons(model)
    #TODO: Handle relationship position sorting 
    # validateEntitySelection()
    # this will be done separately if clearSelected is ever called,
    # validateSelected should be called after

    #relationship lists will be handled in ruby forms rather than by request
window.clearSelected = clearSelected

#TODO: validateSelection(model)
validateSelection = (model) ->
  switch model
    when "entity"
      if window.models["egr"].exists
        query("egr")
      if window.models["epr"].exists
        query("epr")
      #TODO validateNewEgr
    when "group"
      if window.models["gpr"].exists
        query("gpr")
      #TODO validateNewGpr
      #TODO validateNewEgr
    # when "property" #TODO validateNewGpr
    # when "epr"      
    # when "gpr"
    when "egr"
      if window.models["epr"].exists
        query("epr")
  validateActionButtons(model)
window.validateSelection = validateSelection

deactivateButton = (model, button) ->
  $("div.btn."+model+"."+button).addClass("disabled")
#end


activateButton = (model, button) ->
  $("div.btn."+model+"."+button).removeClass("disabled")
#end

validateActionButtons = (model) ->
  if window.models[model].selected.length < 1
    deactivateButton(model, "clear.selection")
    deactivateButton(model, "delete.selection")
    deactivateButton(model, "view.selection")
  else if window.models[model].selected.length == 1
    activateButton(model, "clear.selection")
    activateButton(model, "delete.selection")
    activateButton(model, "view.selection")
    $("div.btn."+model+".view.selection").href = ""
  else if window.models[model].selected.length > 1
    activateButton(model, "clear.selection")
    activateButton(model, "delete.selection")
    deactivateButton(model, "view.selection")
#end

clearAttributes = (modelName) ->
  model = window.models[modelName]
  if model == null
    return false
  model.column = "created_at"
  model.direction = "desc"
  model.page = "1"
window.clearAttributes = clearAttributes

#TODO: verify
formValidation = (modelName) ->
  console.log("validating: " + modelName)
  all_valid = true;
  fields = window.models[modelName].fields
  for fieldName, fieldGroup of fields
    if fields.hasOwnProperty(fieldName)
      fieldGroup.valid = fieldGroup.rx.test($(fieldGroup.field).val())
      if fieldGroup.valid
        $(fieldGroup.label).addClass("label-success")
      else
        $(fieldGroup.label).removeClass("label-success")
        all_valid = false

  if all_valid
    $("input[type=submit]."+modelName).removeClass 'disabled'
  else
    $("input[type=submit]."+modelName).addClass 'disabled'

window.formValidation = formValidation

#TODO: verify
createFormObject = (modelName, fieldName, rx) ->
  fieldGroup = {
    field: "input."+fieldName+".form-field."+modelName,
    label: "span."+fieldName+".form-label."+modelName,
    valid: false,
    rx: rx
  }
  return fieldGroup
#end

createModelFields = (modelName) ->
  switch modelName
    when "entity"
      return {
          "name" : createFormObject(modelName, "name", /^[A-Za-z0-9]+[A-Za-z0-9\-\_]*[A-Za-z0-9]+$/),
          "label" : createFormObject(modelName, "_label", /.*/)
        }
    when "group"
      return {
        "name" : createFormObject(modelName, "name", /^[A-Za-z0-9]+[A-Za-z0-9\-\_]*[A-Za-z0-9]+$/),
        "default_label" : createFormObject(modelName, "default_label", /.*/)
      }
    when "property"
      return {
        "name" : createFormObject(modelName, "name", /^[A-Za-z0-9]+[A-Za-z0-9\-\_]*[A-Za-z0-9]+$/),
        "default_label" : createFormObject(modelName, "default_label", /.*/),
        "units" : createFormObject(modelName, "units", /.*/),
        "units_short" : createFormObject(modelName, "units_short", /.*/),
        "default_value" : createFormObject(modelName, "default_value", /.*/),
      }
    when "role"
      return {
        "name" : createFormObject(modelName, "name", /^[\w\-\_]+([\w\-\_\s]*[\w\-\_]+)*$/),
      }
    when "user"
      return {
        "first" : createFormObject(modelName, "first", /^[\w\-\_]+([\w\-\_\s]*[\w\-\_]+)*$/),
        "last" : createFormObject(modelName, "last", /^[\w\-\_]+([\w\-\_\s]*[\w\-\_]+)*$/),
        "email" : createFormObject(modelName, "email", /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/),
        "login" : createFormObject(modelName, "login", /^[A-Za-z0-9]+[A-Za-z0-9\-\_]*[A-Za-z0-9]+$/),
        "password" : createFormObject(modelName, "password", /^.{6,}$/),
        "confirm_password" : createFormObject(modelName, "confirm_password", /^.{6,}$/),
      }
#end

#verify
getModelFields = (modelName) ->
  console.log("getModelFields()")
  
#end


# #TODO: remove?
# valid = (modelName) ->
#     $("span#entity_name, span#entity_label").addClass "valid"
#     $("input[type=submit]").removeClass 'disabled'
#     $("body").on "keydown", "input.entity", (e) ->
#       console.log "enter valid"
#       if e.keyCode == 13
#         $("form#new_entity").submit()

# #TODO: remove?
# invalid = () ->
#     $("input[type=submit]").addClass 'disabled'
#     $("body").on "keydown", "input.entity", (e) ->
#       console.log "enter invalid"
#       if e.keyCode == 13
#         e.preventDefault()
#         return false
