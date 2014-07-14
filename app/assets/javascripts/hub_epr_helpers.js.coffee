#entity property relationship functions

#epr variables
window.selected_epr_orders = []
window.selected_eprs = [] #list of selected group's properties
window.selected_epr_max_order = -1

$ ->

    #On list element click
    $("body").on "click", '.table tr.epr', (e) ->
        #toggle the selection
        toggleEPRselect this.id, $(this).data().order

    $("td[id^=edit-epr]").on "click", "a", (e) ->
        alert("hello?")
        e.preventDefault()

    $("body").on "click", "#top-selected-eprs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            topEPRs window.selected_eprs

    $("body").on "click", "#up-selected-eprs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            upEPRs window.selected_eprs

    $("body").on "click", "#down-selected-eprs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            downEPRs window.selected_eprs

    $("body").on "click", "#bottom-selected-eprs", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            bottomEPRs window.selected_eprs

#end onLoad function

toggleEPRselect = (id, order) ->
    #if the clicked property is already selected
    id += "" #stringify
    index = $.inArray id, window.selected_eprs
    if index > -1
        window.selected_eprs.splice(index, 1)
        $("tr#"+id+".epr").removeClass "selected-epr"
    else
        $("tr#"+id+".epr").addClass "selected-epr"
        window.selected_eprs.push(id)

    order += "" #stringify
    index = $.inArray order, window.selected_epr_orders
    if index > -1
        window.selected_epr_orders.splice(index, 1)
    else
        window.selected_epr_orders.push order

    validateEPRselection()
window.toggleEPRselect = toggleEPRselect

getEntitysProperties = (relationship_ids) ->
    params = $.param( { 
        selected_egrs: relationship_ids
        selected_properties: window.selected_properties, 
        selected_groups: window.selected_groups, 
        property_search: $("input#property_search_field").val(), 
        property_direction: window.property_direction, 
        property_sort: window.property_sort 
        } )
    $
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/eprs?" + params
        type: 'POST'
window.getEntitysProperties = getEntitysProperties

topEPRs = (relationship_ids) ->
    params = $.param( { 
            selected_eprs: relationship_ids, 
            selected_egrs: window.selected_egrs 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/top_eprs?" + params
        type: 'POST'
window.topEPRs = topEPRs

bottomEPRs = (relationship_ids) ->
    params = $.param( { 
            selected_eprs: relationship_ids, 
            selected_egrs: window.selected_egrs 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/bottom_eprs?" + params
        type: 'POST'
window.bottomEPRs = bottomEPRs

upEPRs = (relationship_ids) ->
    params = $.param( { 
            selected_eprs: relationship_ids, 
            selected_egrs: window.selected_egrs 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/up_eprs?" + params
        type: 'POST'
window.upEPRs = upEPRs

downEPRs = (relationship_ids) ->
    params = $.param( { 
            selected_eprs: relationship_ids, 
            selected_egrs: window.selected_egrs 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/down_eprs?" + params
        type: 'POST'
window.downEPRs = downEPRs

validateEPRselection = () ->
    if window.selected_eprs.length > 0
        $("#clear-selected-eprs").removeClass("disabled")
        $("#delete-selected-eprs").removeClass("disabled")
    else
        $("#clear-selected-eprs").addClass("disabled")
        $("#delete-selected-eprs").addClass("disabled")

    orders = window.selected_epr_orders
    maxOrder = window.selected_epr_max_order + ""

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
            $("div#up-selected-eprs").removeClass "enabled"
            $("div#up-selected-eprs").addClass "disabled"
            $("div#top-selected-eprs").removeClass "enabled"
            $("div#top-selected-eprs").addClass "disabled"
        # index_first = $.inArray "1", orders
        # if index_first > -1 && orders.length == 1
        if sum <= valid
            $("div#up-selected-eprs").removeClass "enabled"
            $("div#up-selected-eprs").addClass "disabled"
            $("div#top-selected-eprs").removeClass "enabled"
            $("div#top-selected-eprs").addClass "disabled"
        else
            $("div#up-selected-eprs").removeClass "disabled"
            $("div#up-selected-eprs").addClass "enabled"
            $("div#top-selected-eprs").removeClass "disabled"
            $("div#top-selected-eprs").addClass "enabled"
        # index_last = $.inArray maxOrder, orders
        sum = 0
        valid = false
        index = $.inArray window.selected_epr_max_order + "", orders
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
                $("div#down-selected-eprs").removeClass "enabled"
                $("div#down-selected-eprs").addClass "disabled"
                $("div#bottom-selected-eprs").removeClass "enabled"
                $("div#bottom-selected-eprs").addClass "disabled"
        unless valid
            $("div#down-selected-eprs").removeClass "enabled"
            $("div#down-selected-eprs").addClass "disabled"
            $("div#bottom-selected-eprs").removeClass "enabled"
            $("div#bottom-selected-eprs").addClass "disabled"
        else
            $("div#down-selected-eprs").removeClass "disabled"
            $("div#down-selected-eprs").addClass "enabled"
            $("div#bottom-selected-eprs").removeClass "disabled"
            $("div#bottom-selected-eprs").addClass "enabled"


window.validateEPRselection = validateEPRselection
