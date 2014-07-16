#entity group relationship functions

window.selected_egrs = []
window.selected_egr_orders = [] #list of selected entity's groups order
window.selected_egr_max_order = -1 

$ ->

    #On EntityGroupRelationship element click
    $("body").on "click", '.table tr.egr', (e) ->
        #get the group id
        toggleEGRselect this.id, $(this).data().order, e.ctrlKey || e.metaKey

    #When the add groups button is clicked
    $("body").on "click", "#add-selected-groups", (e) ->
        #if it's enabled
        if $(this).hasClass "enabled"
            addGroupsToEntity window.selected_groups, window.selected_entity

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-egrs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedEGRs()
            validateEGRselection()

    #When the delete egr button is clicked
    $("body").on "click", "#delete-selected-egrs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            deleteEntityGroupRelations window.selected_egrs

    $("body").on "click", "#top-selected-egrs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            topEntityGroupRelations window.selected_egrs

    $("body").on "click", "#up-selected-egrs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            upEntityGroupRelations window.selected_egrs

    $("body").on "click", "#down-selected-egrs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            downEntityGroupRelations window.selected_egrs

    $("body").on "click", "#bottom-selected-egrs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            bottomEntityGroupRelations window.selected_egrs

#end onLoad function

toggleEGRselect = (id, order, multiSelect) ->
    #if the clicked group is already selected
    id += "" #stringify
    index = $.inArray id, window.selected_egrs
    if index > -1
        if window.selected_egrs.length > 1 && !multiSelect
            clearSelectedEGRs()
            $("tr#"+id+".egr").addClass "selected-egr"
            window.selected_egrs.push(id)
        else
            clearSelectedEPRs()
            window.selected_egrs.splice(index, 1)
            $("tr#"+id+".egr").removeClass "selected-egr"
    else if multiSelect
        $("tr#"+id+".egr").addClass "selected-egr"
        window.selected_egrs.push(id)
    else
        clearSelectedEGRs()
        $("tr#"+id+".egr").addClass "selected-egr"
        window.selected_egrs.push(id)

    order += "" #stringify
    index = $.inArray order, window.selected_egr_orders
    if index > -1
        window.selected_egr_orders.splice(index, 1)
    else
        window.selected_egr_orders.push order

    getEntitysProperties window.selected_egrs
    validateEGRselection()
window.toggleEGRselect = toggleEGRselect

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
        url: "/hub/create_egrs?" + params
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
        url: "/hub/delete_egrs?" + params
        type: 'POST'
window.deleteEntityGroupRelations = deleteEntityGroupRelations

validateEGRselection = () ->
    if window.selected_egrs.length > 0
        $("#clear-selected-egrs").removeClass("disabled")
        $("#delete-selected-egrs").removeClass("disabled")
        clearSelectedGroups()
    else
        _html = ""
        if window.selected_groups.length < 1
            _html = "<div class='alert alert-info small-font center'>"
            _html += "<i>No Group selected.</i></div>"
            $("#gprs").html ""
        $("#groups-properties-alert").html _html
        $("#clear-selected-egrs").addClass("disabled")
        $("#delete-selected-egrs").addClass("disabled")

    orders = window.selected_egr_orders
    maxOrder = window.selected_egr_max_order + ""

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
            $("div#up-selected-egrs").removeClass "enabled"
            $("div#up-selected-egrs").addClass "disabled"
            $("div#top-selected-egrs").removeClass "enabled"
            $("div#top-selected-egrs").addClass "disabled"
        # index_first = $.inArray "1", orders
        # if index_first > -1 && orders.length == 1
        if sum <= valid
            $("div#up-selected-egrs").removeClass "enabled"
            $("div#up-selected-egrs").addClass "disabled"
            $("div#top-selected-egrs").removeClass "enabled"
            $("div#top-selected-egrs").addClass "disabled"
        else
            $("div#up-selected-egrs").removeClass "disabled"
            $("div#up-selected-egrs").addClass "enabled"
            $("div#top-selected-egrs").removeClass "disabled"
            $("div#top-selected-egrs").addClass "enabled"
        # index_last = $.inArray maxOrder, orders
        sum = 0
        valid = false
        index = $.inArray window.selected_egr_max_order + "", orders
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
                $("div#down-selected-egrs").removeClass "enabled"
                $("div#down-selected-egrs").addClass "disabled"
                $("div#bottom-selected-egrs").removeClass "enabled"
                $("div#bottom-selected-egrs").addClass "disabled"
        unless valid
            $("div#down-selected-egrs").removeClass "enabled"
            $("div#down-selected-egrs").addClass "disabled"
            $("div#bottom-selected-egrs").removeClass "enabled"
            $("div#bottom-selected-egrs").addClass "disabled"
        else
            $("div#down-selected-egrs").removeClass "disabled"
            $("div#down-selected-egrs").addClass "enabled"
            $("div#bottom-selected-egrs").removeClass "disabled"
            $("div#bottom-selected-egrs").addClass "enabled"


window.validateEGRselection = validateEGRselection

clearSelectedEGRs = () ->
    window.selected_egrs = []
    window.selected_egr_orders = []
    # window.selected_egr_max_order = -1
    $("tr.selected-egr").removeClass "selected-egr"
    clearSelectedEPRs()
window.clearSelectedEGRs = clearSelectedEGRs

getEGRs = (id) ->
    params = $.param( { 
        selected_entity: id, 
        selected_groups: window.selected_groups, 
        group_search: $("input#group_search_field").val(), 
        group_direction: window.group_direction, 
        group_sort: window.group_sort, 
        groups_page: window.groups_page,
        event: 'egrs'
        } )
    $
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/egrs?" + params
        type: 'POST'
window.getEGRs = getEGRs

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
        url: "/hub/top_egrs?" + params
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
        url: "/hub/bottom_egrs?" + params
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
        url: "/hub/up_egrs?" + params
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
        url: "/hub/down_egrs?" + params
        type: 'POST'
window.downEntityGroupRelations = downEntityGroupRelations

