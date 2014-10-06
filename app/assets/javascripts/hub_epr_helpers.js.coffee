#entity property relationship functions

#= require epr_edit_helpers

#epr variables
window.selected_epr_positions = []
window.selected_eprs = [] #list of selected group's properties
window.selected_epr_max_position = -1

$ ->

    if $('body').hasClass "hub"

        #On list element click
        $("body").on "click", '.table tr.epr', (e) ->
            #toggle the selection
            toggleEPRselect this.id, $(this).data().position, e.metaKey || e.ctrlKey

        $("body").on "click", "td.edit-epr-trigger", (e) ->
            toggleEPRform this
            e.preventDefault()

        $("body").on "click", "#top-selected-eprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                moveEPRs "top"
                # topEPRs window.selected_eprs

        $("body").on "click", "#up-selected-eprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                moveEPRs "up"
                # upEPRs window.selected_eprs

        $("body").on "click", "#down-selected-eprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                moveEPRs "down"
                # downEPRs window.selected_eprs

        $("body").on "click", "#bottom-selected-eprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                moveEPRs "bottom"
                # bottomEPRs window.selected_eprs

        $("body").on "click", "#clear-selected-eprs", (e) ->
            unless $(this).hasClass "disabled"
                closeAllEPRforms()
                clearSelectedEPRs()


#end onLoad function


toggleEPRform = ( element ) ->
  openForm = $(element).hasClass('openForm')
  open = []
  if openForm 
      id = element.id
      $(element).removeClass('openForm')
      $('#'+id+".edit-epr-form").animate({ height: 'toggle', opacity: 'toggle'}, 'slow')
  else
      open = $('td.edit-epr-trigger.openForm')
      if( open.length == 1)
          id = open[0].id
          open.removeClass('openForm')
          $('#'+id+'.edit-epr-form').animate({ height: 'toggle', opacity: 'toggle'}, 'slow')
      $(element).addClass('openForm')
      id = element.id
      $('#'+id+'.edit-epr-form').slideDown()

closeAllEPRforms = () ->
  open = $('td.edit-epr-trigger.openForm')
  for element in open 
      $("#"+element.id+".edit-epr-form").animate({ height: 'toggle', opacity: 'toggle'}, 'slow')
  open.removeClass('openForm')
window.closeAllEPRforms = closeAllEPRforms

toggleEPRselect = (id, position, multiSelect) ->
    #if the clicked property is already selected
    id += "" #stringify
    index = $.inArray id, window.selected_eprs
    if index > -1
        if window.selected_eprs.length > 1 && !multiSelect
            clearSelectedEPRs()
            $("tr#"+id+".epr").addClass "selected-epr"
            window.selected_eprs.push(id)
        else
            window.selected_eprs.splice(index, 1)
            $("tr#"+id+".epr").removeClass "selected-epr"
    else if multiSelect
        $("tr#"+id+".epr").addClass "selected-epr"
        window.selected_eprs.push(id)
    else
        clearSelectedEPRs()
        $("tr#"+id+".epr").addClass "selected-epr"
        window.selected_eprs.push(id)

    position += "" #stringify
    index = $.inArray position, window.selected_epr_positions
    if index > -1
        window.selected_epr_positions.splice(index, 1)
    else
        window.selected_epr_positions.push position

    validateEPRselection()
window.toggleEPRselect = toggleEPRselect

clearSelectedEPRs = () ->
    console.log "called clear selected eprs"
    window.selected_eprs = []
    window.selected_epr_positions = []
    $("tr.selected-epr").removeClass "selected-epr"
    validateEPRselection()
window.clearSelectedEPRs = clearSelectedEPRs

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

moveEPRs = (direction) ->
    params = $.param( { 
            selected_eprs: window.selected_eprs, 
            selected_egrs: window.selected_egrs, 
            move: direction
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/move_eprs?" + params
        type: 'POST'

validateClearButton = () ->
    open = $("td.edit-epr-trigger.openForm")
    if window.selected_eprs.length > 0 && window.selected_egrs.length == 1 || open.length > 0
        $("#clear-selected-eprs").removeClass("disabled")
    else
        $("#clear-selected-eprs").addClass("disabled")

validateEPRselection = () ->
    validateClearButton()
    
    positions = window.selected_epr_positions

    if positions.length < 1 || window.selected_egrs.length > 1
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
            $("div#up-selected-eprs").removeClass "enabled"
            $("div#up-selected-eprs").addClass "disabled"
            $("div#top-selected-eprs").removeClass "enabled"
            $("div#top-selected-eprs").addClass "disabled"
        # index_first = $.inArray "1", positions
        # if index_first > -1 && positions.length == 1
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
        # index_last = $.inArray maxPosition, positions
        valid = false
        index = $.inArray window.selected_epr_max_position + "", positions
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
