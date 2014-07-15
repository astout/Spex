window.selected_groups = [] #list of selected groups
window.group_sort = "created_at"
window.group_direction = "desc"
window.groups_page = "1"

$ ->

    #ajaxify new group collapse form
    $("#new-group-collapse-heading").on "click", (e) ->
        e.preventDefault()

    #on group list element click
    $("body").on "click", '.table tr.group', (e) ->
        toggleGroupSelect this.id, e.ctrlKey || e.metaKey

    #Ajaxify Group List Sorting
    $('#groups').on 'click', "th a", (e) ->
        window.group_sort = getParameterByName "group_sort", this.href
        window.group_direction = getParameterByName "group_direction", this.href
        params = getGroupParams()

        #send the request
        $.get "/hub?" + params
        false

    #Every character change in Search field, submit query
    $("input#group_search_field").on 'input', ->
        window.groups_page = "1"
        params = getGroupParams()
        #send the request
        $.get "/hub?" + params
        false
        # $("input#selected_entity").val window.selected_entity
        # $("#search_group").submit()

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-groups", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedGroups()

    #When the delete groups button is clicked
    $("body").on "click", "#delete-selected-groups", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            deleteGroups window.selected_groups

#end onLoad function

getGroupParams = () ->
    params = $.param( { 
            selected_groups: window.selected_groups,
            group_search: $("input#group_search_field").val(), 
            group_direction: window.group_direction, 
            group_sort: window.group_sort, 
            groups_page: window.groups_page,
            event: "group"
            } )
    return params
window.getGroupParams = getGroupParams

#Ensure ajaxified pagination buttons on any additions to list
groupPagination = () ->
    console.log "called group pagination"
    #Ajaxify List Page changes
    $("div#groups").on "click", '.pagination a', (e) ->
        window.groups_page = getParameterByName( "groups_page", this.href ) || "1"
        params = getGroupParams()
        #send the request
        $.get "/hub?" + params
        false
window.groupPagination = groupPagination

#hub group functions
toggleGroupSelect = (id, multiSelect) ->
    index = $.inArray(id, window.selected_groups)
    if index > -1
        if window.selected_groups.length > 1 && !multiSelect
            clearSelectedGroups()
            $("tr#"+id+".group").addClass "selected-group"
            window.selected_groups.push(id)
        else
            $("tr#"+id+".group").removeClass "selected-group"
            window.selected_groups.splice(index, 1)
    else if multiSelect
        $("tr#"+id+".group").addClass "selected-group"
        window.selected_groups.push(id)
    else
        clearSelectedGroups()
        $("tr#"+id+".group").addClass "selected-group"
        window.selected_groups.push(id)
    getGroupsProperties window.selected_groups
    validateGroupSelection()
window.toggleGroupSelect = toggleGroupSelect

validateGroupSelection = () ->
    if window.selected_groups.length > 0
        $("#clear-selected-groups").removeClass("disabled")
        $("#delete-selected-groups").removeClass("disabled")
        clearSelectedEGRs()
        validateEntitysGroupSelection()
    else
        _html = ""
        if window.selected_egrs.length < 1
            _html = "<div class='alert alert-info small-font center'>"
            _html += "<i>No Group selected.</i></div>"
        $("#groups_properties").html ""
        $("#groups-properties-alert").html _html
        $("#clear-selected-groups").addClass("disabled")
        $("#delete-selected-groups").addClass("disabled")
    clearSelectedGPRs()
    validateAddGroupsToEntity()
    validateAddPropertiesToGroup()
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
    #selection cleared and validated on response
window.deleteGroups = deleteGroups

clearSelectedGroups = () ->
    window.selected_groups = []
    $("tr.selected-group").removeClass "selected-group"
    clearSelectedGPRs()
window.clearSelectedGroups = clearSelectedGroups

clearGroupAttributes = () ->
    window.group_sort = "created_at"
    window.group_direction = "desc"
    window.groups_page = "1"
window.clearGroupAttributes = clearGroupAttributes
