#group property relationship functions

window.selected_group_property_orders = [] #list of selected entity's groups order
window.selected_group_property_relations = [] #list of selected group's properties
window.selected_groups_max_property_order = -1

$ ->

    #On list element click
    $("body").on "click", '.table tr.group_property_relationship', (e) ->
        #get the group id
        toggleGroupPropertySelect this.id, $(this).data().order

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-groups-properties", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedGroupsProperties()

    #When the add properties button is clicked
    $("body").on "click", "#add-selected-properties", (e) ->
        #if it's enabled
        if $(this).hasClass "enabled"
            addPropertiesToGroup window.selected_properties, window.selected_groups

#end onLoad function

clearSelectedGroupsProperties = () ->
    window.selected_group_property_relations = []
    $("tr.selected-groups-property").removeClass "selected-groups-property"
    validateGroupsPropertySelection()
window.clearSelectedGroupsProperties = clearSelectedGroupsProperties

validateAddPropertiesToGroup = () ->
    #if there are selected groups && a selected entity,
    #enable the add-groups button
    if window.selected_properties.length > 0 && window.selected_groups.length == 1
        $("#add-selected-properties").removeClass("disabled")
        $("#add-selected-properties").addClass("enabled")
    else
        $("#add-selected-properties").removeClass("enabled")
        $("#add-selected-properties").addClass("disabled")
window.validateAddPropertiesToGroup = validateAddPropertiesToGroup

addPropertiesToGroup = (properties, group) ->
    #ajaxify the selected parameters
    params = $.param( { 
        selected_groups: window.selected_groups, 
        selected_properties: window.selected_properties,
        property_direction: window.property_direction,
        property_sort: window.property_sort,
        property_search: $("input#property_search_field").val() 
        } )
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/group_add_properties?" + params
        type: 'POST'
window.addPropertiesToGroup = addPropertiesToGroup  

toggleGroupPropertySelect = (id, order) ->
    #if the clicked property is already selected
    id += "" #stringify
    index = $.inArray id, window.selected_group_property_relations
    if index > -1
        window.selected_group_property_relations.splice(index, 1)
        $("tr#"+id+".group_property_relationship").removeClass "selected-groups-property"
    else
        $("tr#"+id+".group_property_relationship").addClass "selected-groups-property"
        window.selected_group_property_relations.push(id)

    order += "" #stringify
    index = $.inArray order, window.selected_group_property_orders
    if index > -1
        window.selected_group_property_orders.splice(index, 1)
    else
        window.selected_group_property_orders.push order

    validateGroupsPropertySelection()
window.toggleGroupPropertySelect = toggleGroupPropertySelect

getGroupsProperties = (ids) ->
    params = $.param( { 
        selected_groups: ids, 
        selected_properties: window.selected_properties, 
        property_search: $("input#property_search_field").val(), 
        property_direction: window.property_direction, 
        property_sort: window.property_sort 
        } )
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/groups_properties?" + params
        type: 'POST'
window.getGroupsProperties = getGroupsProperties

clearSelectedGroupsProperties = () ->
    window.selected_group_property_relations = []
    window.selected_group_property_orders = []
    $("tr.selected-groups-property").removeClass "selected-groups-property"
    validateGroupsPropertySelection()
window.clearSelectedGroupsProperties = clearSelectedGroupsProperties

validateGroupsPropertySelection = () ->
    if window.selected_group_property_relations.length > 0
        $("#clear-selected-groups-properties").removeClass("disabled")
        $("#delete-selected-groups-properties").removeClass("disabled")
    else
        $("#clear-selected-groups-properties").addClass("disabled")
        $("#delete-selected-groups-properties").addClass("disabled")

    orders = window.selected_group_property_orders
    maxOrder = window.selected_groups_max_property_order + ""

    if orders.length < 1
        $("div.property-order-action").removeClass "enabled"
        $("div.property-order-action").addClass "disabled"
    else
        valid = orders.length * ( orders.length + 1) / 2
        sum = 0
        try 
            sum += eval(order) for order in orders
        catch e
            console.log e
        finally
            $("div#up-selected-groups-properties").removeClass "enabled"
            $("div#up-selected-groups-properties").addClass "disabled"
            $("div#top-selected-groups-properties").removeClass "enabled"
            $("div#top-selected-groups-properties").addClass "disabled"
        # index_first = $.inArray "1", orders
        # if index_first > -1 && orders.length == 1
        if sum <= valid
            $("div#up-selected-groups-properties").removeClass "enabled"
            $("div#up-selected-groups-properties").addClass "disabled"
            $("div#top-selected-groups-properties").removeClass "enabled"
            $("div#top-selected-groups-properties").addClass "disabled"
        else
            $("div#up-selected-groups-properties").removeClass "disabled"
            $("div#up-selected-groups-properties").addClass "enabled"
            $("div#top-selected-groups-properties").removeClass "disabled"
            $("div#top-selected-groups-properties").addClass "enabled"
        # index_last = $.inArray maxOrder, orders
        sum = 0
        valid = false
        index = $.inArray window.selected_groups_max_property_order + "", orders
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
                $("div#down-selected-groups-properties").removeClass "enabled"
                $("div#down-selected-groups-properties").addClass "disabled"
                $("div#bottom-selected-groups-properties").removeClass "enabled"
                $("div#bottom-selected-groups-properties").addClass "disabled"
        unless valid
            $("div#down-selected-groups-properties").removeClass "enabled"
            $("div#down-selected-groups-properties").addClass "disabled"
            $("div#bottom-selected-groups-properties").removeClass "enabled"
            $("div#bottom-selected-groups-properties").addClass "disabled"
        else
            $("div#down-selected-groups-properties").removeClass "disabled"
            $("div#down-selected-groups-properties").addClass "enabled"
            $("div#bottom-selected-groups-properties").removeClass "disabled"
            $("div#bottom-selected-groups-properties").addClass "enabled"


window.validateGroupsPropertySelection = validateGroupsPropertySelection