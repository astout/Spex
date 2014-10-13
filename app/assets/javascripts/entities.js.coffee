# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require entity_reports

$ ->

    if $("body").hasClass("entities")

      console.log "setting up entities"

      #globals
      window.selected_entity = "-1"
      window.entities_page = "1"
      window.entity_direction = "desc"
      window.entity_sort = "updated_at"
      window.entity_search = ""

      #if there's an alert on the page, make it fade out
      # delay 3000, -> 
      #   $("div.alert").fadeOut(1500)

      $('div.entities.list').on 'click', "th a", (e) ->
          window.entity_sort = getParameterByName "entity_sort", this.href
          window.entity_direction = getParameterByName "entity_direction", this.href
          entityQuery()
          false

      #Actions/Settings for collapsing the 'Create New' panel
      $("#new-entity-collapse-heading").on "click", (e) ->
          e.preventDefault()

      #On list element click, highlight it and make it the selected item
      #Also list any associated egrs
      $("body").on "click", '.table tr.entity', (e) ->
          toggleEntitySelect(this.id)

      #When the clear entity button is clicked
      $("body").on "click", "div.entity.clear-selection", (e) ->
          #if it's enabled
          unless $(this).hasClass "disabled"
              clearSelectedEntity()

      #When the delete entity button is clicked
      $("body").on "click", "div.entity.delete-selection", (e) ->
          #if it's enabled
          unless $(this).hasClass "disabled"
              deleteModal window.selected_entity
              console.log "delete btn clicked"
              # deleteEntity window.selected_entity

      $("body").on "click", "div.btn.entity.view", (e) ->
          unless $(this).hasClass "disabled"
            Turbolinks.visit("entities/" + window.selected_entity)

      #Every character change in Search field, submit query
      $("body").on "input", "input#entity_search_field", (e) ->
          console.log $(this).val()
          console.log "typed in search"
          entityQuery()
          false

      $("body").on "click", "span.entity.delete", (e) ->
          deleteModal(this.id)
          console.log "delete clicked"

      $("body").on "click", "button#btn-delete-confirm", (e) ->
          console.log "confirm delete"
          params = $.param( {
              id: $("span.delete-entity-id")[0].id
              })
          $.ajax
              url: "/entities/confirm_delete?" + params
              type: 'POST'

    if $("form.new_entity").length > 0 || $("form.edit_entity").length > 0
      $("input#entity_name, input#entity_label, input#entity_img").on "input", ->
          NewEntityValidation()
      NewEntityValidation()

deleteModal = (_id) ->
    if _id.length < 1
        return false
    params = $.param( { 
      id: _id,
      } )
    $.ajax 
      url: "/entities/delete_request?" + params
      type: 'POST'

get_entity_params = () ->
    console.log "getting entity params"
    params = $.param( {
        selected_entity: window.selected_entity,
        entity_search: $("input#entity_search_field").val(), 
        entity_direction: window.entity_direction,
        entity_sort: window.entity_sort,
        entities_page: window.entities_page,
        event: "entity"
    })
    console.log("params")
    return params
window.get_entity_params = get_entity_params

entityQuery = () ->
  console.log "querying entity"
  params = get_entity_params()
  $.get "entity_query?" + params
window.entityQuery = entityQuery

#Ensure ajaxified pagination buttons on any additions to list
entityPagination = () ->
    #Ajaxify List Page changes
    $("div#entities").on "click", '.pagination a', (e) ->
        window.entities_page = getParameterByName( "entities_page", this.href ) || "1"
        entityQuery()
        false
window.entityPagination = entityPagination

toggleEntitySelect = (id) ->
    $("tr.selected-entity").removeClass("selected-entity")
    clearSelectedEGRs()
    validateEGRselection()

    if window.selected_entity == id
        clearSelectedEntity()
    else
        $("tr#"+id+".entity").addClass "selected-entity"
        window.selected_entity = id + ""
        $("input#selected_entity").val id

        #TODO: only get EGRs if there is a place to list them on the page

        # getEGRs id
        egr_query()
        validateEntitySelection()
window.toggleEntitySelect = toggleEntitySelect

clearSelectedEntity = () ->
    $("tr.selected-entity").removeClass "selected-entity"
    window.selected_entity = -1
    window.selected_egr_max_position = -1
    validateEntitySelection()

    #TODO: only get EGRs if there is a place to list them on the page
    # getEGRs window.selected_entity
    egr_query()
window.clearSelectedEntity = clearSelectedEntity

validateEntitySelection = () ->
    #clear the selected entity's groupsd partial if no entity is selected
    if window.selected_entity < 0
        _html = "<div class='alert alert-info small-font center'>"
        _html += "<i>No Entity selected.</i></div>"
        $("#egrs").html ""
        $("#entitys-groups-alert").html _html
        $("div.entity.clear-selection").addClass("disabled")
        $("div.entity.delete-selection").addClass("disabled")
        $("div.btn.entity.view").addClass("disabled")
    else
        $("div.entity.clear-selection").removeClass("disabled")
        $("div.entity.delete-selection").removeClass("disabled")
        $("div.btn.entity.view").removeClass("disabled")
    validateAddGroupsToEntity()
window.validateEntitySelection = validateEntitySelection

# deleteEntity = (id) ->
#     params = $.param( { 
#         selected_entity: id, 
#         selected_groups: window.selected_groups,
#         group_search: $("input#group_search_field").val(), 
#         entity_search: $("input#entity_search_field").val(), 
#         group_direction: window.group_direction, 
#         entity_direction: window.entity_direction, 
#         group_sort: window.group_sort,  
#         entity_sort: window.entity_sort  
#         } )

#     #send the request to add the selected groups to the selected entity
#     $.ajax 
#         url: "/hub/delete_entity?" + params
#         type: 'POST'

#     validateEntitySelection()
# window.deleteEntity = deleteEntity  

clearEntityAttributes = () ->
    window.entity_sort = "created_at"
    window.entity_direction = "desc"
    window.entities_page = "1"
window.clearEntityAttributes = clearEntityAttributes


NewEntityValidation = () ->
    name = $("input#entity_name").val()
    label = $("input#entity_label").val()

    rx = /^[A-Za-z0-9]+[A-Za-z0-9\-\_]*[A-Za-z0-9]+$/

    if name.length > 0 && rx.test(name)
        unless $("span#entity_name").hasClass "valid"
            $("span#entity_name").addClass "valid"
        valid()
    else
        $("span#entity_name").removeClass "valid"
        invalid()

    unless $("span#entity_label").hasClass "valid"
        $("span#entity_label").addClass "valid"
window.NewEntityValidation = NewEntityValidation

valid = () ->
    $("span#entity_name, span#entity_label").addClass "valid"
    $("input[type=submit]").removeClass 'disabled'
    $("body").on "keydown", "input.entity", (e) ->
      console.log "enter valid"
      if e.keyCode == 13
        $("form#new_entity").submit()

invalid = () ->
    $("input[type=submit]").addClass 'disabled'
    $("body").on "keydown", "input.entity", (e) ->
      console.log "enter invalid"
      if e.keyCode == 13
        e.preventDefault()
        return false
