window.selected_entity = -1 #only one selected entity at a time
window.entity_sort = "created_at"
window.entity_direction = "desc"
window.entities_page = "1"

$ ->

    if $('body').hasClass "hub"
        #Ajaxify List Sorting
        $('#entities').on 'click', "th a", (e) ->
            window.entity_sort = getParameterByName "entity_sort", this.href
            window.entity_direction = getParameterByName "entity_direction", this.href
            params = getEntityParams()
            #send the request
            $.get "/hub?" + params
            false

        #Actions/Settings for collapsing the 'Create New' panel
        $("#new-entity-collapse-heading").on "click", (e) ->
            e.preventDefault()

        #Every character change in Search field, submit query
        $("input#entity_search_field").on 'input', ->
            window.entities_page = "1"
            params = getEntityParams()
            #send the request
            $.get "/hub?" + params
            false

        #On list element click, highlight it and make it the selected item
        #Also list any associated egrs
        $("body").on "click", '.table tr.entity', (e) ->
            toggleEntitySelect(this.id)

        #When the clear entity button is clicked
        $("body").on "click", "#clear-selected-entity", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                clearSelectedEntity()

        #When the delete entity button is clicked
        $("body").on "click", "#delete-selected-entity", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                deleteEntity window.selected_entity

#end onLoad function

getEntityParams = () ->
    params = $.param( { 
            selected_entity: window.selected_entity,
            entity_search: $("input#entity_search_field").val(), 
            entity_direction: window.entity_direction, 
            entity_sort: window.entity_sort,  
            entities_page: window.entities_page,
            event: "entity"
            } )
    return params
window.getEntityParams = getEntityParams

#Ensure ajaxified pagination buttons on any additions to list
entityPagination = () ->
    #Ajaxify List Page changes
    $("div#entities").on "click", '.pagination a', (e) ->
        window.entities_page = getParameterByName( "entities_page", this.href ) || "1"
        params = getEntityParams()
        #send the request
        $.get "/hub?" + params
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
        getEGRs id
        validateEntitySelection()
window.toggleEntitySelect = toggleEntitySelect

clearSelectedEntity = () ->
    $("tr.selected-entity").removeClass "selected-entity"
    window.selected_entity = -1
    window.selected_egr_max_position = -1
    validateEntitySelection()
    getEGRs window.selected_entity
window.clearSelectedEntity = clearSelectedEntity

validateEntitySelection = () ->
    #clear the selected entity's groupsd partial if no entity is selected
    if window.selected_entity < 0
        _html = "<div class='alert alert-info small-font center'>"
        _html += "<i>No Entity selected.</i></div>"
        $("#egrs").html ""
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

clearEntityAttributes = () ->
    window.entity_sort = "created_at"
    window.entity_direction = "desc"
    window.entities_page = "1"
window.clearEntityAttributes = clearEntityAttributes
