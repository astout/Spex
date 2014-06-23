# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#globalize the selected items
window.selected_entity = -1 #only one selected entity at a time
window.selected_groups = [] #list of selected groups
window.group_sort = "created_at"
window.entity_sort = "created_at"
window.group_direction = "desc"
window.entity_direction = "desc"
window.loadCount = 0

$ ->

    #Ajaxify Entity List Sorting
    $('#entities').on 'click', "th a", ->
        window.entity_sort = getParameterByName "entity_sort", this.href
        window.entity_direction = getParameterByName "entity_direction", this.href
        $.getScript(this.href)
        false

    #Ajaxify Group List Sorting
    $('#groups').on 'click', "th a", ->
        window.group_sort = getParameterByName "group_sort", this.href
        window.group_direction = getParameterByName "group_direction", this.href
        $.getScript(this.href)
        false

    #Ajaxify Page changes
    $("body").on "click", '.pagination a', (e) ->
        e.preventDefault()
        $.getScript(this.href)
        false

    # #Ajaxify Entity Deleting
    # $('tr.entity').on 'click', "td.delete-entity", (e) ->
    #     e.preventDefault()
    #     $.getScript(this.href)
    #     false

    #Ajaxify Entity Deleting
    $('tr.group').on 'click', "td.delete-group", (e) ->
        e.preventDefault()
        $.getScript(this.href)
        false

    #Every character change in Group Search field, submit query
    $("input#group_search_field").on 'input', ->
        $("input#selected_entity").val window.selected_entity
        $("#search_group").submit()

    #Every character change in Entity Search field, submit query
    $("input#entity_search_field").on 'input', ->
        $("#search_entity").submit()

    #On Entity list element click, highlight it and make it the selected entity
    #Also list any groups the entity owns
    $("body").on "click", '.table tr.entity', (e) ->
        
        #if it is already selected, deselect it
        if $(this).hasClass "selected-entity"
            $(this).removeClass "selected-entity"
            window.selected_entity = -1

        else #deselect what is selected and make the clicked entity selected
            $(".selected-entity").removeClass("selected-entity")
            $(this).addClass "selected-entity"
            window.selected_entity = this.id
            #look up the Entity's groups
            params = $.param( { 
                selected_entity: window.selected_entity, 
                selected_groups: window.selected_groups, 
                group_search: $("input#group_search_field").val(), 
                group_direction: window.group_direction, 
                group_sort: window.group_sort 
                } )
            $
            #send the request to add the selected groups to the selected entity
            $.ajax 
                url: "/hub/entitys_groups?" + params
                type: 'POST'

        checkSelected()


    #on group list element click
    $("body").on "click", '.table tr.group', (e) ->

        #get the group id
        group_id = this.id

        #if the clicked group is already selected
        if $(this).hasClass "selected-group"

            #deselect, remove styling
            $(this).removeClass "selected-group"

            groupDeselect group_id

        else #if not selected
            #add selected styling
            $(this).addClass "selected-group"

            groupSelect group_id
        

    #When the add groups button is clicked
    $("body").on "click", "#add-selected-groups", (e) ->
        
        #if it's enabled
        if $(this).hasClass "enabled"
            #ajaxify the selected parameters
            params = $.param( { selected_entity: window.selected_entity, selected_groups: window.selected_groups } )
            #send the request to add the selected groups to the selected entity
            $.ajax 
                url: "/hub/entity_add_groups?" + params
                type: 'POST'

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            window.selected_groups = []
            checkSelected()
            persistStyling()

    #When the clear entity button is clicked
    $("body").on "click", "#clear-selected-entity", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            window.selected_entity = -1
            checkSelected()
            persistStyling()

    #When the delete entity button is clicked
    $("body").on "click", "#delete-selected-entity", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"

            params = $.param( { 
                selected_entity: window.selected_entity, 
                selected_groups: window.selected_groups,
                group_search: $("input#group_search_field").val(), 
                entity_search: $("input#entity_search_field").val(), 
                group_direction: window.group_direction, 
                entity_direction: window.entity_direction, 
                group_sort: window.group_sort,  
                entity_sort: window.entity_sort  
                } )

            #clear entity search
            # $("input#entity_search_field").val('')

            #send the request to add the selected groups to the selected entity
            $.ajax 
                url: "/hub/delete_entity?" + params
                type: 'POST'

            checkSelected()
            persistStyling()

    #When the delete groups button is clicked
    $("body").on "click", "#delete-selected-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"

            params = $.param( { 
                selected_entity: window.selected_entity, 
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
                url: "/hub/delete_groups?" + params
                type: 'POST'

            checkSelected()
            persistStyling()



checkSelected = () ->
    #if there are selected groups && a selected entity,
    #enable the add-groups button
    if window.selected_groups.length > 0 && window.selected_entity > -1
        $("#add-selected-groups").removeClass("disabled")
        $("#add-selected-groups").addClass("enabled")
    else
        $("#add-selected-groups").removeClass("enabled")
        $("#add-selected-groups").addClass("disabled")

    if window.selected_groups.length > 0
        $("#clear-selected-groups").removeClass("disabled")
        $("#delete-selected-groups").removeClass("disabled")
    else
        $("#clear-selected-groups").addClass("disabled")
        $("#delete-selected-groups").addClass("disabled")

    #clear the selected entity's groupsd partial if no entity is selected
    if window.selected_entity < 0
        _html = "<div class='alert alert-info small-font'>"
        _html += "<i>No Entity selected.</i></div>"
        $("#entitys_groups").html ""
        $("#entitys-groups-alert").html _html
        $("#clear-selected-entity").addClass("disabled")
        $("#delete-selected-entity").addClass("disabled")
    else
        $("#clear-selected-entity").removeClass("disabled")
        $("#delete-selected-entity").removeClass("disabled")


groupDeselect = (id) ->
    #remove from list of selected groups
    index = $.inArray(id, window.selected_groups)
    if index > -1
        window.selected_groups.splice(index, 1)
    checkSelected()
window.groupDeselect = groupDeselect

groupSelect = (id) ->
    index = $.inArray(id, window.selected_groups)
    unless index > -1
        window.selected_groups.push(id)
    checkSelected()
window.groupSelect = groupSelect

entityDeselect = () ->
    #remove from list of selected groups
    window.selected_entity = -1
    checkSelected()
window.entityDeselect = entityDeselect

entitySelect = (id) ->
    window.selected_entity = id + ""
    checkSelected()
window.entitySelect = entitySelect


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

#globalize persistStyling        
window.persistStyling = persistStyling

        
