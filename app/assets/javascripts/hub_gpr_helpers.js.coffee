#group property relationship functions

window.selected_gpr_positions = [] #list of selected entity's groups position
window.selected_gprs = [] #list of selected group's properties
window.selected_gpr_max_position = -1

$ ->

    if $('body').hasClass "hub"
        #On list element click
        $("body").on "click", '.table tr.gpr', (e) ->
            #get the group id
            toggleGPRselect this.id, $(this).data().position, e.metaKey || e.ctrlKey

        #When the clear groups button is clicked
        $("body").on "click", "#clear-selected-gprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                clearSelectedGPRs()

        #When the add properties button is clicked
        $("body").on "click", "#add-selected-properties", (e) ->
            #if it's enabled
            if $(this).hasClass "enabled"
                createGPRs window.selected_properties, window.selected_groups

        #When the delete egr button is clicked
        $("body").on "click", "#delete-selected-gprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                deleteGPRs window.selected_gprs

        $("body").on "click", "#top-selected-gprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                topGPRs window.selected_gprs

        $("body").on "click", "#up-selected-gprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                upGPRs window.selected_gprs

        $("body").on "click", "#down-selected-gprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                downGPRs window.selected_gprs

        $("body").on "click", "#bottom-selected-gprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                bottomGPRs window.selected_gprs

#end onLoad function

validateCreateGPR = () ->
    #if there are selected groups && a selected entity,
    #enable the add-groups button
    if window.selected_properties.length > 0 && window.selected_groups.length == 1
        $("#add-selected-properties").removeClass("disabled")
        $("#add-selected-properties").addClass("enabled")
    else
        $("#add-selected-properties").removeClass("enabled")
        $("#add-selected-properties").addClass("disabled")
window.validateCreateGPR = validateCreateGPR

createGPRs = (properties, group) ->
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
        url: "/hub/create_gprs?" + params
        type: 'POST'
window.createGPRs = createGPRs  

toggleGPRselect = (id, position, multiSelect) ->
    #if the clicked property is already selected

    id += "" #stringify
    index = $.inArray id, window.selected_gprs
    if index > -1
        if window.selected_gprs.length > 1 && !multiSelect
            clearSelectedGPRs()
            $("tr#"+id+".gpr").addClass "selected-gpr"
            window.selected_gprs.push(id)
        else
            window.selected_gprs.splice(index, 1)
            $("tr#"+id+".gpr").removeClass "selected-gpr"
    else if multiSelect
        $("tr#"+id+".gpr").addClass "selected-gpr"
        window.selected_gprs.push(id)
    else
        clearSelectedGPRs()
        $("tr#"+id+".gpr").addClass "selected-gpr"
        window.selected_gprs.push(id)

    position += "" #stringify
    index = $.inArray position, window.selected_gpr_positions
    if index > -1
        window.selected_gpr_positions.splice(index, 1)
    else
        window.selected_gpr_positions.push position

    validateGroupsPropertySelection()
window.toggleGPRselect = toggleGPRselect

getGPRs = (ids) ->
    params = $.param( { 
        selected_groups: ids, 
        selected_properties: window.selected_properties, 
        property_search: $("input#property_search_field").val(), 
        property_direction: window.property_direction, 
        property_sort: window.property_sort 
        } )
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/gprs?" + params
        type: 'POST'
window.getGPRs = getGPRs

clearSelectedGPRs = () ->
    window.selected_gprs = []
    window.selected_gpr_positions = []
    $("tr.selected-gpr").removeClass "selected-gpr"
    validateGroupsPropertySelection()
window.clearSelectedGPRs = clearSelectedGPRs

deleteGPRs = (relationship_ids) ->
    params = $.param( { 
        selected_gprs: relationship_ids, 
        selected_groups: window.selected_groups,
        property_search: $("input#property_search_field").val(), 
        property_direction: window.property_direction, 
        property_sort: window.property_sort 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/delete_gprs?" + params
        type: 'POST'
window.deleteGPRs = deleteGPRs

topGPRs = (relationship_ids) ->
    params = $.param( { 
            selected_gprs: relationship_ids, 
            selected_groups: window.selected_groups 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/top_gprs?" + params
        type: 'POST'
window.topGPRs = topGPRs

bottomGPRs = (relationship_ids) ->
    params = $.param( { 
            selected_gprs: relationship_ids, 
            selected_groups: window.selected_groups 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/bottom_gprs?" + params
        type: 'POST'
window.bottomGPRs = bottomGPRs

upGPRs = (relationship_ids) ->
    params = $.param( { 
            selected_gprs: relationship_ids, 
            selected_groups: window.selected_groups 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/up_gprs?" + params
        type: 'POST'
window.upGPRs = upGPRs

downGPRs = (relationship_ids) ->
    params = $.param( { 
            selected_gprs: relationship_ids, 
            selected_groups: window.selected_groups 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/down_gprs?" + params
        type: 'POST'
window.downGPRs = downGPRs

validateGroupsPropertySelection = () ->
    if window.selected_gprs.length > 0 && window.selected_groups.length == 1
        $("#clear-selected-gprs").removeClass("disabled")
        $("#delete-selected-gprs").removeClass("disabled")
    else
        $("#clear-selected-gprs").addClass("disabled")
        $("#delete-selected-gprs").addClass("disabled")

    positions = window.selected_gpr_positions

    if positions.length < 1 || window.selected_groups.length > 1
        $("div.property-position-action").removeClass "enabled"
        $("div.property-position-action").addClass "disabled"
    else
        valid = positions.length * ( positions.length + 1) / 2
        sum = 0
        try 
            sum += eval(position) for position in positions
        catch e
            console.log e
        finally
            $("div#up-selected-gprs").removeClass "enabled"
            $("div#up-selected-gprs").addClass "disabled"
            $("div#top-selected-gprs").removeClass "enabled"
            $("div#top-selected-gprs").addClass "disabled"
        # index_first = $.inArray "1", positions
        # if index_first > -1 && positions.length == 1
        if sum <= valid
            $("div#up-selected-gprs").removeClass "enabled"
            $("div#up-selected-gprs").addClass "disabled"
            $("div#top-selected-gprs").removeClass "enabled"
            $("div#top-selected-gprs").addClass "disabled"
        else
            $("div#up-selected-gprs").removeClass "disabled"
            $("div#up-selected-gprs").addClass "enabled"
            $("div#top-selected-gprs").removeClass "disabled"
            $("div#top-selected-gprs").addClass "enabled"
        # index_last = $.inArray maxPosition, positions
        valid = false
        index = $.inArray window.selected_gpr_max_position + "", positions
        if index < 0
            valid = true
        else
        # if positions.length == 1
        #     if index < 0
        #         valid = true
        # else
            try
                positions.sort()
                # for(i = 0; i < positions.length - 1; i++)
                #     test = eval(positions[i]) + eval(positions[i+1])
                #     if test > 1
                #         valid = true
                #         break
                i = 0
                while i < positions.length - 1
                  test = eval(positions[i+1]) - eval(positions[i])
                  if test > 1
                    valid = true
                    break
                  i++
            catch e
                console.log e
            finally
                $("div#down-selected-gprs").removeClass "enabled"
                $("div#down-selected-gprs").addClass "disabled"
                $("div#bottom-selected-gprs").removeClass "enabled"
                $("div#bottom-selected-gprs").addClass "disabled"
        unless valid
            $("div#down-selected-gprs").removeClass "enabled"
            $("div#down-selected-gprs").addClass "disabled"
            $("div#bottom-selected-gprs").removeClass "enabled"
            $("div#bottom-selected-gprs").addClass "disabled"
        else
            $("div#down-selected-gprs").removeClass "disabled"
            $("div#down-selected-gprs").addClass "enabled"
            $("div#bottom-selected-gprs").removeClass "disabled"
            $("div#bottom-selected-gprs").addClass "enabled"


window.validateGroupsPropertySelection = validateGroupsPropertySelection