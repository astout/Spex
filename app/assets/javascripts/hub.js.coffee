# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require hub_helpers
#= require hub_entity_helpers
#= require hub_property_helpers
#= require hub_group_helpers
#= require hub_egr_helpers
#= require hub_epr_helpers
#= require hub_gpr_helpers

$ ->

    #disable autocomplete across all forms
    $("input[type='text']").prop("autocomplete", "off")
    
    $("div[id^=accordion]").on('hidden.bs.collapse', toggleChevron)
    $("div[id^=accordion]").on('shown.bs.collapse', toggleChevron)

    #Clear all alerts
    $("body").on "click", "#clear-alerts", (e) ->
        hubAlert "", ""

    ajaxPagination()

getAllParams = () ->
    params = $.param( { 
            selected_entity: window.selected_entity,
            selected_egrs: window.selected_egrs, 
            selected_groups: window.selected_groups,
            selected_properties: window.selected_properties,
            group_search: $("input#group_search_field").val(), 
            entity_search: $("input#entity_search_field").val(), 
            property_search: $("input#property_search_field").val(), 
            group_direction: window.group_direction, 
            entity_direction: window.entity_direction, 
            property_direction: window.property_direction, 
            group_sort: window.group_sort, 
            entity_sort: window.entity_sort,  
            property_sort: window.property_sort,
            groups_page: window.groups_page,
            entities_page: window.entities_page,
            properties_page: window.properties_page
            } )
    return params
window.getAllParams = getAllParams

toggleChevron = (e) ->
    $(e.target)
        .prev '.panel-heading'
        .find 'i.collapse-indicator'
        .toggleClass 'glyphicon-chevron-down glyphicon-chevron-right'
window.toggleChevron = toggleChevron

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

    if window.selected_egrs.length > 0
        for relationship_id in window.selected_egrs
            $("tr#"+relationship_id+".egr").addClass "selected-egr"
    else
        $("tr.selected-egr").removeClass "selected-egr"

    if window.selected_properties.length > 0
        for property in window.selected_properties
            $("tr#"+property+".property").addClass "selected-property"
    else
        $("tr.selected-properties").removeClass "selected-properties"

    if window.selected_gprs.length > 0
        for relationship_id in window.selected_gprs
            $("tr#"+relationship_id+".gpr").addClass "selected-gpr"
    else
        $("tr.selected-gpr").removeClass "selected-gpr"

    if window.selected_eprs.length > 0
        for epr in window.selected_eprs
            $("tr#"+epr+".epr").addClass "selected-epr"
    else
        $("tr.selected-epr").removeClass "selected-epr"

#globalize persistStyling        
window.persistStyling = persistStyling

#Ensure ajaxified pagination buttons on any additions to lists
ajaxPagination = () ->
    entityPagination()
    groupPagination()
    propertyPagination()
    # console.log "called ajax pagination"
    # #Ajaxify All List Page changes
    # $("body").on "click", '.pagination a', (e) ->
    #     window.entities_page = getParameterByName "entities_page", this.href || "1"
    #     window.properties_page = getParameterByName "properties_page", this.href || "1"
    #     window.groups_page = getParameterByName "groups_page", this.href || "1"
    #     # params = getAllParams()
    #     #send the request
    #     $.get "/hub?" + params
    #     false
window.ajaxPagination = ajaxPagination

#creates an alert in the specified document id with the given html
#clears all other alert divs
hubAlert = (documentId, html) ->
    #clear all alerts
    $("#hub-alert").html ""
    # $("#entitys-groups-alert").html ""
    $("#entity-alert").html ""
    $("#group-alert").html ""

    #update the given div to the html
    if documentId.length < 1
        $("#entitys-groups-alert").html ""
    else
        $(documentId).html ""
        $(documentId).html html

window.hubAlert = hubAlert
