# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#globalize the selected items
window.selected_entity = -1 #only one selected entity at a time
window.selected_groups = [] #list of selected groups
window.selected_entity_group_relations = [] #list of selected entity's groups
window.group_sort = "created_at"
window.entity_sort = "created_at"
window.group_direction = "desc"
window.entity_direction = "desc"
window.loadCount = 0

$ ->

    #Ajaxify Entity List Sorting
    $('#entities').on 'click', "th a", (e) ->
        window.entity_sort = getParameterByName "entity_sort", this.href
        window.entity_direction = getParameterByName "entity_direction", this.href
        $.getScript(this.href)
        false

    #Ajaxify Group List Sorting
    $('#groups').on 'click', "th a", (e) ->
        window.group_sort = getParameterByName "group_sort", this.href
        window.group_direction = getParameterByName "group_direction", this.href
        $.getScript(this.href)
        false

    #Ajaxify Page changes
    $("body").on "click", '.pagination a', (e) ->
        e.preventDefault()
        $.getScript(this.href)
        false

    #Every character change in Group Search field, submit query
    $("input#group_search_field").on 'input', ->
        $("input#selected_entity").val window.selected_entity
        $("#search_group").submit()

    #Every character change in Entity Search field, submit query
    $("input#entity_search_field").on 'input', ->
        $("#search_entity").submit()

    #On Entity list element click, highlight it and make it the selected entity
    #Also list any groups the entity owns
    $("body").on "click", '.table tr.entity', (e) ->

        toggleEntitySelect(this.id)
        

    #On EntityGroupRelationship element click, highlight it and make it the selected group
    $("body").on "click", '.table tr.entity_group_relationship', (e) ->
       
        #get the group id
        toggleEntitysGroupSelect this.id


    #on group list element click
    $("body").on "click", '.table tr.group', (e) ->

        toggleGroupSelect this.id

    #When the add groups button is clicked
    $("body").on "click", "#add-selected-groups", (e) ->
        
        #if it's enabled
        if $(this).hasClass "enabled"
            addGroupsToEntity window.selected_groups, window.selected_entity
            

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedGroups()

    #When the clear entity button is clicked
    $("body").on "click", "#clear-selected-entity", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedEntity()

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-entitys-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedEntitysGroups()

    #When the delete entity button is clicked
    $("body").on "click", "#delete-selected-entity", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"

            deleteEntity window.selected_entity


    #When the delete groups button is clicked
    $("body").on "click", "#delete-selected-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"

            deleteGroups window.selected_groups

    #When the delete groups button is clicked
    $("body").on "click", "#delete-selected-entitys-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"

            deleteEntitysGroups window.selected_entity_group_relations
            

toggleEntitySelect = (id) ->
    $("tr.selected-entity").removeClass("selected-entity")
    clearSelectedEntitysGroups()

    if window.selected_entity == id
        clearSelectedEntity()

    else
        $("tr#"+id+".entity").addClass "selected-entity"
        window.selected_entity = id + ""
        getEntitysGroups id
        validateEntitySelection()

window.toggleEntitySelect = toggleEntitySelect

clearSelectedEntity = () ->
    $("tr.selected-entity").removeClass "selected-entity"
    window.selected_entity = -1
    validateEntitySelection()
window.clearSelectedEntity = clearSelectedEntity

validateEntitySelection = () ->
    #clear the selected entity's groupsd partial if no entity is selected
    if window.selected_entity < 0
        _html = "<div class='alert alert-info small-font'>"
        _html += "<i>No Entity selected.</i></div>"
        $("#entitys_groups").html ""
        $("#entitys-groups-alert").html _html
        $("#clear-selected-entity").addClass("disabled")
        $("#delete-selected-entity").addClass("disabled")
    else
        $("#clear-selected-entity").removeClass("disabled")
        $("#delete-selected-entity").removeClass("disabled")
    validateAddGroupsToEntity()
window.validateEntitySelection = validateEntitySelection

deleteEntity = (id) ->
    params = $.param( { 
        selected_entity: id, 
        selected_groups: window.selected_groups,
        group_search: $("input#group_search_field").val(), 
        entity_search: $("input#entity_search_field").val(), 
        group_direction: window.group_direction, 
        entity_direction: window.entity_direction, 
        group_sort: window.group_sort,  
        entity_sort: window.entity_sort  
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/delete_entity?" + params
        type: 'POST'

    validateEntitySelection()

window.deleteEntity = deleteEntity  

validateAddGroupsToEntity = () ->
    #if there are selected groups && a selected entity,
    #enable the add-groups button
    if window.selected_groups.length > 0 && window.selected_entity > -1
        $("#add-selected-groups").removeClass("disabled")
        $("#add-selected-groups").addClass("enabled")
    else
        $("#add-selected-groups").removeClass("enabled")
        $("#add-selected-groups").addClass("disabled")
window.validateAddGroupsToEntity = validateAddGroupsToEntity

addGroupsToEntity = (groups, entity) ->
    #ajaxify the selected parameters
    params = $.param( { selected_entity: window.selected_entity, selected_groups: window.selected_groups } )
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/entity_add_groups?" + params
        type: 'POST'
window.addGroupsToEntity = addGroupsToEntity  

deleteEntityGroupRelations = (relationship_id) ->
    params = $.param( { 
        selected_entity: window.selected_entity,
        selected_entity_group_relations: relationship_id, 
        selected_groups: window.selected_groups,
        group_search: $("input#group_search_field").val(), 
        entity_search: $("input#entity_search_field").val(), 
        group_direction: window.group_direction, 
        entity_direction: window.entity_direction, 
        group_sort: window.group_sort, 
        entity_sort: window.entity_sort  
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/delete_entity_group_relation?" + params
        type: 'POST'

    validateEntitysGroupSelection()
window.deleteGroups = deleteGroups

toggleGroupSelect = (id) ->
    index = $.inArray(id, window.selected_groups)
    if index > -1
        $("tr#"+id+".group").removeClass "selected-group"
        window.selected_groups.splice(index, 1)
    else
        $("tr#"+id+".group").addClass "selected-group"
        window.selected_groups.push(id)
    validateGroupSelection()
window.toggleGroupSelect = toggleGroupSelect

validateGroupSelection = () ->
    if window.selected_groups.length > 0
        $("#clear-selected-groups").removeClass("disabled")
        $("#delete-selected-groups").removeClass("disabled")
    else
        $("#clear-selected-groups").addClass("disabled")
        $("#delete-selected-groups").addClass("disabled")
    validateAddGroupsToEntity()
window.validateGroupSelection = validateGroupSelection

deleteGroups = (groups) ->
    params = $.param( { 
        selected_entity: window.selected_entity, 
        selected_groups: groups,
        group_search: $("input#group_search_field").val(), 
        entity_search: $("input#entity_search_field").val(), 
        group_direction: window.group_direction, 
        entity_direction: window.entity_direction, 
        group_sort: window.group_sort, 
        entity_sort: window.entity_sort  
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/delete_groups?" + params
        type: 'POST'

    validateGroupSelection()
window.deleteGroups = deleteGroups

clearSelectedGroups = () ->
    window.selected_groups = []
    $("tr.selected-group").removeClass "selected-group"
    validateGroupSelection()
window.clearSelectedGroups = clearSelectedGroups

toggleEntitysGroupSelect = (id) ->
    #if the clicked group is already selected
    index = $.inArray id, window.selected_entity_group_relations
    if index > -1
        window.selected_entity_group_relations.splice(index, 1)
        $("tr#"+id+".entity_group_relationship").removeClass "selected-entitys-group"
    else
        $("tr#"+id+".entity_group_relationship").addClass "selected-entitys-group"
        window.selected_entity_group_relations.push(id)
    validateEntitysGroupSelection()
window.toggleEntitysGroupSelect = toggleEntitysGroupSelect

validateEntitysGroupSelection = () ->
    if window.selected_entity_group_relations.length > 0
        $("#clear-selected-entitys-groups").removeClass("disabled")
        $("#delete-selected-entitys-groups").removeClass("disabled")
    else
        $("#clear-selected-entitys-groups").addClass("disabled")
        $("#delete-selected-entitys-groups").addClass("disabled")
window.validateEntitysGroupSelection = validateEntitysGroupSelection

clearSelectedEntitysGroups = () ->
    window.selected_entity_group_relations = []
    $("tr.selected-entitys-group").removeClass "selected-entitys-group"
    validateEntitysGroupSelection()
window.clearSelectedEntitysGroups = clearSelectedEntitysGroups

getEntitysGroups = (id) ->
    params = $.param( { 
        selected_entity: id, 
        selected_groups: window.selected_groups, 
        group_search: $("input#group_search_field").val(), 
        group_direction: window.group_direction, 
        group_sort: window.group_sort 
        } )
    $
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/entitys_groups?" + params
        type: 'POST'
window.getEntitysGroups = getEntitysGroups

persistStyling = () ->
    if window.selected_entity > -1
        $("tr#"+window.selected_entity+".entity").addClass "selected-entity"
    else
        $("tr.selected-entity").removeClass "selected-entity"

    if window.selected_groups.length > 0
        for group in window.selected_groups
            $("tr#"+group+".group").addClass "selected-group"
    else
        $("tr.selected-group").removeClass "selected-group"

    if window.selected_entity_group_relations.length > 0
        for relationship_id in window.selected_entity_group_relations
            $("tr#"+relationship_id+".entity_group_relationship").addClass "selected-entitys-group"
    else
        $("tr.selected-entitys-group").removeClass "selected-entitys-group"

#globalize persistStyling        
window.persistStyling = persistStyling