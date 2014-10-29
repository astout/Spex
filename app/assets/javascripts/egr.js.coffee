# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



$ ->

    #for now, only do this on main egr query page
    if $('body').hasClass "entity_group_relationships"

      #globals
      window.selected_egrs = []
      window.egr_page = "1"
      window.egr_direction = "desc"
      window.egr_sort = "updated_at"
      window.egr_search = ""

      #When the add groups button is clicked
      $("body").on "click", "#add-selected-groups", (e) ->
          #if it's enabled
          if $(this).hasClass "enabled"
              addGroupsToEntity window.selected_groups, window.selected_entities

      #On EntityGroupRelationship element click
      $("body").on "click", '.table tr.egr', (e) ->
          #get the group id
          toggleEGRselect this.id, $(this).data().position, e.ctrlKey || e.metaKey

      #When the clear groups button is clicked
      $("body").on "click", "div.egr.clear-selection", (e) ->
          #if it's enabled
          unless $(this).hasClass "disabled"
              clearSelectedEGRs()
              validateEGRselection()

      #When the delete egr button is clicked
      $("body").on "click", "div.egr.delete-selection", (e) ->
          #if it's enabled
          unless $(this).hasClass "disabled"
              deleteEntityGroupRelations window.selected_egrs

      $("body").on "click", "div.btn.egr.view", (e) ->
          unless $(this).hasClass "disabled"
            Turbolinks.visit("/entity_group_relationships/" + window.selected_egrs[0] + "/edit")

      egrLoad()

#end onLoad()

# deleteEntityGroupRelations = (relationship_ids) ->
#     params = $.param( { 
#         selected_entities: window.selected_entities,
#         selected_egrs: relationship_ids, 
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
#         url: "/hub/delete_egrs?" + params
#         type: 'POST'
# window.deleteEntityGroupRelations = deleteEntityGroupRelations

validateAddGroupsToEntity = () ->
    #if there are selected groups && a selected entity,
    #enable the add-groups button
    if window.selected_groups.length > 0 && window.selected_entities.length > 0
        $("#add-selected-groups").removeClass("disabled")
        $("#add-selected-groups").addClass("enabled")
    else
        $("#add-selected-groups").removeClass("enabled")
        $("#add-selected-groups").addClass("disabled")
window.validateAddGroupsToEntity = validateAddGroupsToEntity

addGroupsToEntity = (groups, entity) ->
    #ajaxify the selected parameters
    params = $.param( { 
        selected_entities: window.selected_entities, 
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

toggleEGRselect = (id, position, multiSelect) ->
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

    position += "" #stringify
    index = $.inArray position, window.selected_egr_positions
    if index > -1
        window.selected_egr_positions.splice(index, 1)
    else
        window.selected_egr_positions.push position

    getEntitysProperties window.selected_egrs
    validateEGRselection()
window.toggleEGRselect = toggleEGRselect

validateEGRselection = () ->
    if window.selected_egrs.length > 0
        $("div.egr.clear-selection").removeClass("disabled")
        $("div.egr.delete-selection").removeClass("disabled")
        clearSelectedGroups()
    else
        _html = ""
        if window.selected_groups.length < 1
            _html = "<div class='alert alert-info small-font center'>"
            _html += "<i>No Group selected.</i></div>"
            $("#gprs").html ""
        $("#groups-properties-alert").html _html
        $("div.egr.clear-selection").addClass("disabled")
        $("div.egr.delete-selection").addClass("disabled")

    if window.selected_egrs.length > 0
    	$("div.egr.view").removeClass("disabled")
    else
    	$("div.egr.view").addClass("disabled")

 #    if window.selected_egrs.length === 1
 #    	$("div.egr.view").removeClass("disabled")
	# elsif window.selected_egrs 
 #    	$("div.egr.view").removeClass("disabled")

    positions = window.selected_egr_positions
    maxPosition = window.selected_egr_max_position + ""

    if positions.length < 1
        $("div.group-position-action").removeClass "enabled"
        $("div.group-position-action").addClass "disabled"
    else
        valid = positions.length * ( positions.length + 1) / 2
        sum = 0
        try 
            sum += eval(position) for position in positions
        catch e
            console.log e
        finally
            $("div#up-selected-egrs").removeClass "enabled"
            $("div#up-selected-egrs").addClass "disabled"
            $("div#top-selected-egrs").removeClass "enabled"
            $("div#top-selected-egrs").addClass "disabled"
        # index_first = $.inArray "1", positions
        # if index_first > -1 && positions.length == 1
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
        # index_last = $.inArray maxPosition, positions
        sum = 0
        valid = false
        index = $.inArray window.selected_egr_max_position + "", positions
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
    window.selected_egr_positions = []
    # window.selected_egr_max_position = -1
    $("tr.selected-egr").removeClass "selected-egr"
    clearSelectedEPRs()
window.clearSelectedEGRs = clearSelectedEGRs

get_egr_params = () ->
    params = $.param( {
        selected_egrs: window.selected_egrs || [],
        selected_entities: window.selected_entities || [],
        egr_search: $("input#egr_search_field").val(), 
        egr_direction: window.egr_direction, 
        egr_sort: window.egr_sort,  
        egr_page: window.egr_page,
        view_id: window.view_id,
        event: "egr"
    })
    return params
window.get_egr_params = get_egr_params

#public
#query on egr params
egr_query = () ->
  params = get_egr_params()
  $.get "egr_query?" + params
window.egr_query = egr_query

#public
#Ensure ajaxified pagination buttons on any additions to list
egrPagination = () ->
    console.log "ajaxifying egr pagination"
    #Ajaxify List Page changes
    $("div#egr_list > .pagination").on "click", 'a', (e) ->
        console.log "egr page link clicked"
        e.preventDefault()
        window.egr_page = getParameterByName( "egr_page", this.href ) || "1"
        #send the request
        egr_query()
        false
window.egrPagination = egrPagination

#private
#do this on load
egrLoad = () ->

  egrPagination()
  #Every character change in Search field, submit query
  $("body").on 'input', "input#egr_search_field", (e) ->
      window.egr_page = "1"
      #send the request
      egr_query()
      false
#end egrLoad

#anytime there is an update to the egr data
egrRefresh = () ->
  egrPagination()
  $("body").on 'input', "input#egr_search_field", (e) ->
      #send the request
      egr_query()
      false
window.egrRefresh = egrRefresh