#entity group relationship functions

window.selected_egrs = []
window.selected_entity_group_orders = [] #list of selected entity's groups order
window.selected_entitys_max_group_order = -1 

$ ->

    #On EntityGroupRelationship element click
    $("body").on "click", '.table tr.entity_group_relationship', (e) ->
        #get the group id
        toggleEntitysGroupSelect this.id, $(this).data().order, e.ctrlKey || e.metaKey

    #When the add groups button is clicked
    $("body").on "click", "#add-selected-groups", (e) ->
        #if it's enabled
        if $(this).hasClass "enabled"
            addGroupsToEntity window.selected_groups, window.selected_entity

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-entitys-groups", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedEGRs()
            validateEntitysGroupSelection()

    #When the delete egr button is clicked
    $("body").on "click", "#delete-selected-entitys-groups", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            deleteEntityGroupRelations window.selected_egrs

    $("body").on "click", "#top-selected-entitys-groups", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            topEntityGroupRelations window.selected_egrs

    $("body").on "click", "#up-selected-entitys-groups", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            upEntityGroupRelations window.selected_egrs

    $("body").on "click", "#down-selected-entitys-groups", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            downEntityGroupRelations window.selected_egrs

    $("body").on "click", "#bottom-selected-entitys-groups", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            bottomEntityGroupRelations window.selected_egrs

#end onLoad function

toggleEntitysGroupSelect = (id, order, multiSelect) ->
    #if the clicked group is already selected
    id += "" #stringify
    index = $.inArray id, window.selected_egrs
    if index > -1
        if window.selected_egrs.length > 1 && !multiSelect
            clearSelectedEGRs()
            $("tr#"+id+".entity_group_relationship").addClass "selected-entitys-group"
            window.selected_egrs.push(id)
        else
            clearSelectedEPRs()
            window.selected_egrs.splice(index, 1)
            $("tr#"+id+".entity_group_relationship").removeClass "selected-entitys-group"
    else if multiSelect
        $("tr#"+id+".entity_group_relationship").addClass "selected-entitys-group"
        window.selected_egrs.push(id)
    else
        clearSelectedEGRs()
        $("tr#"+id+".entity_group_relationship").addClass "selected-entitys-group"
        window.selected_egrs.push(id)

    order += "" #stringify
    index = $.inArray order, window.selected_entity_group_orders
    if index > -1
        window.selected_entity_group_orders.splice(index, 1)
    else
        window.selected_entity_group_orders.push order

    getEntitysProperties window.selected_egrs
    validateEntitysGroupSelection()
window.toggleEntitysGroupSelect = toggleEntitysGroupSelect

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
    params = $.param( { 
        selected_entity: window.selected_entity, 
        selected_groups: window.selected_groups,
        group_direction: window.group_direction,
        group_sort: window.group_sort,
        group_search: $("input#group_search_field").val() 
        } )
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/entity_add_groups?" + params
        type: 'POST'
window.addGroupsToEntity = addGroupsToEntity  

deleteEntityGroupRelations = (relationship_ids) ->
    params = $.param( { 
        selected_entity: window.selected_entity,
        selected_egrs: relationship_ids, 
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
        url: "/hub/delete_entity_group_relations?" + params
        type: 'POST'
window.deleteEntityGroupRelations = deleteEntityGroupRelations

validateEntitysGroupSelection = () ->
    if window.selected_egrs.length > 0
        $("#clear-selected-entitys-groups").removeClass("disabled")
        $("#delete-selected-entitys-groups").removeClass("disabled")
        clearSelectedGroups()
    else
        _html = ""
        if window.selected_groups.length < 1
            _html = "<div class='alert alert-info small-font center'>"
            _html += "<i>No Group selected.</i></div>"
            $("#groups_properties").html ""
        $("#groups-properties-alert").html _html
        $("#clear-selected-entitys-groups").addClass("disabled")
        $("#delete-selected-entitys-groups").addClass("disabled")

    orders = window.selected_entity_group_orders
    maxOrder = window.selected_entitys_max_group_order + ""

    if orders.length < 1
        $("div.group-order-action").removeClass "enabled"
        $("div.group-order-action").addClass "disabled"
    else
        valid = orders.length * ( orders.length + 1) / 2
        sum = 0
        try 
            sum += eval(order) for order in orders
        catch e
            console.log e
        finally
            $("div#up-selected-entitys-groups").removeClass "enabled"
            $("div#up-selected-entitys-groups").addClass "disabled"
            $("div#top-selected-entitys-groups").removeClass "enabled"
            $("div#top-selected-entitys-groups").addClass "disabled"
        # index_first = $.inArray "1", orders
        # if index_first > -1 && orders.length == 1
        if sum <= valid
            $("div#up-selected-entitys-groups").removeClass "enabled"
            $("div#up-selected-entitys-groups").addClass "disabled"
            $("div#top-selected-entitys-groups").removeClass "enabled"
            $("div#top-selected-entitys-groups").addClass "disabled"
        else
            $("div#up-selected-entitys-groups").removeClass "disabled"
            $("div#up-selected-entitys-groups").addClass "enabled"
            $("div#top-selected-entitys-groups").removeClass "disabled"
            $("div#top-selected-entitys-groups").addClass "enabled"
        # index_last = $.inArray maxOrder, orders
        sum = 0
        valid = false
        index = $.inArray window.selected_entitys_max_group_order + "", orders
        if index < 0
            valid = true
        else
        # if orders.length == 1
        #     if index < 0
        #         valid = true
        # else
            try
                orders.sort()
                # for(i = 0; i < orders.length - 1; i++)
                #     test = eval(orders[i]) + eval(orders[i+1])
                #     if test > 1
                #         valid = true
                #         break
                i = 0
                while i < orders.length - 1
                  test = eval(orders[i+1]) - eval(orders[i])
                  if test > 1
                    valid = true
                    break
                  i++
            catch e
                console.log e
            finally
                $("div#down-selected-entitys-groups").removeClass "enabled"
                $("div#down-selected-entitys-groups").addClass "disabled"
                $("div#bottom-selected-entitys-groups").removeClass "enabled"
                $("div#bottom-selected-entitys-groups").addClass "disabled"
        unless valid
            $("div#down-selected-entitys-groups").removeClass "enabled"
            $("div#down-selected-entitys-groups").addClass "disabled"
            $("div#bottom-selected-entitys-groups").removeClass "enabled"
            $("div#bottom-selected-entitys-groups").addClass "disabled"
        else
            $("div#down-selected-entitys-groups").removeClass "disabled"
            $("div#down-selected-entitys-groups").addClass "enabled"
            $("div#bottom-selected-entitys-groups").removeClass "disabled"
            $("div#bottom-selected-entitys-groups").addClass "enabled"


window.validateEntitysGroupSelection = validateEntitysGroupSelection

clearSelectedEGRs = () ->
    window.selected_egrs = []
    window.selected_entity_group_orders = []
    # window.selected_entitys_max_group_order = -1
    $("tr.selected-entitys-group").removeClass "selected-entitys-group"
    clearSelectedEPRs()
window.clearSelectedEGRs = clearSelectedEGRs

getEntitysGroups = (id) ->
    params = $.param( { 
        selected_entity: id, 
        selected_groups: window.selected_groups, 
        group_search: $("input#group_search_field").val(), 
        group_direction: window.group_direction, 
        group_sort: window.group_sort, 
        groups_page: window.groups_page,
        event: 'entitys_groups'
        } )
    $
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/entitys_groups?" + params
        type: 'POST'
window.getEntitysGroups = getEntitysGroups

topEntityGroupRelations = (relationship_ids) ->
    params = $.param( { 
        selected_entity: window.selected_entity,
        selected_egrs: relationship_ids.sort(), 
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
        url: "/hub/top_entity_group_relations?" + params
        type: 'POST'
window.topEntityGroupRelations = topEntityGroupRelations

bottomEntityGroupRelations = (relationship_ids) ->
    params = $.param( { 
        selected_entity: window.selected_entity,
        selected_egrs: relationship_ids.sort(), 
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
        url: "/hub/bottom_entity_group_relations?" + params
        type: 'POST'
window.bottomEntityGroupRelations = bottomEntityGroupRelations

upEntityGroupRelations = (relationship_ids) ->
    params = $.param( { 
        selected_entity: window.selected_entity,
        selected_egrs: relationship_ids.sort(), 
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
        url: "/hub/up_entity_group_relations?" + params
        type: 'POST'
window.upEntityGroupRelations = upEntityGroupRelations

downEntityGroupRelations = (relationship_ids) ->
    params = $.param( { 
        selected_entity: window.selected_entity,
        selected_egrs: relationship_ids.sort(), 
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
        url: "/hub/down_entity_group_relations?" + params
        type: 'POST'
window.downEntityGroupRelations = downEntityGroupRelations

