# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#globalize the selected items
window.selected_entity = -1 #only one selected entity at a time
window.selected_groups = [] #list of selected groups
window.selected_properties = [] #list of selected groups
window.selected_entity_group_relations = [] #list of selected entity's groups
window.selected_entity_group_orders = [] #list of selected entity's groups order
window.selected_entitys_max_group_order = -1
window.selected_entitys_group_max_property_order = -1
window.group_sort = "created_at"
window.property_sort = "created_at"
window.entity_sort = "created_at"
window.group_direction = "desc"
window.property_direction = "desc"
window.entity_direction = "desc"
window.groups_page = "1"
window.entities_page = "1"
window.properties_page = "1"

$ ->

    #Actions/Settings for collapsing the 'Create New' windows
    $("#new-entity-collapse-heading").on "click", (e) ->
        e.preventDefault()
    $("#new-group-collapse-heading").on "click", (e) ->
        e.preventDefault()
    $("#new-property-collapse-heading").on "click", (e) ->
        e.preventDefault()
    $("div[id^=accordion]").on('hidden.bs.collapse', toggleChevron)
    $("div[id^=accordion]").on('shown.bs.collapse', toggleChevron)

    #Clear all alerts
    $("body").on "click", "#clear-alerts", (e) ->
        hubAlert "", ""

    #Ajaxify Entity List Sorting
    $('#entities').on 'click', "th a", (e) ->
        window.entity_sort = getParameterByName "entity_sort", this.href
        window.entity_direction = getParameterByName "entity_direction", this.href
        params = $getAllParams()

        #send the request
        $.get "/hub?" + params
        false

    #Ajaxify Group List Sorting
    $('#groups').on 'click', "th a", (e) ->
        window.group_sort = getParameterByName "group_sort", this.href
        window.group_direction = getParameterByName "group_direction", this.href
        params = $getAllParams()

        #send the request
        $.get "/hub?" + params
        false

    #Ajaxify Group List Sorting
    $('#properties').on 'click', "th a", (e) ->
        window.property_sort = getParameterByName "property_sort", this.href
        window.property_direction = getParameterByName "property_direction", this.href
        params = $getAllParams()

        #send the request
        $.get "/hub?" + params
        false

    ajaxPagination()

    #Every character change in Group Search field, submit query
    $("input#group_search_field").on 'input', ->
        $("input#selected_entity").val window.selected_entity
        $("#search_group").submit()

    #Every character change in Entity Search field, submit query
    $("input#entity_search_field").on 'input', ->
        $("#search_entity").submit()

    #Every character change in Property Search field, submit query
    $("input#property_search_field").on 'input', ->
        $("input#selected_group").val window.selected_group
        $("#search_property").submit()

    #On Entity list element click, highlight it and make it the selected entity
    #Also list any groups the entity owns
    $("body").on "click", '.table tr.entity', (e) ->

        toggleEntitySelect(this.id)
        

    #On EntityGroupRelationship element click
    $("body").on "click", '.table tr.entity_group_relationship', (e) ->
       
        #get the group id
        toggleEntitysGroupSelect this.id, $(this).data().order


    #on group list element click
    $("body").on "click", '.table tr.group', (e) ->

        toggleGroupSelect this.id

    #When the add groups button is clicked
    $("body").on "click", "#add-selected-groups", (e) ->
        
        #if it's enabled
        if $(this).hasClass "enabled"
            addGroupsToEntity window.selected_groups, window.selected_entity

    #When the add properties button is clicked
    $("body").on "click", "#add-selected-properties", (e) ->
        
        #if it's enabled
        if $(this).hasClass "enabled"
            addPropertiesToGroup window.selected_properties, window.selected_groups
            

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedGroups()

    #on group list element click
    $("body").on "click", '.table tr.property', (e) ->

        togglePropertySelect this.id

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-properties", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedProperties()

    #When the clear entity button is clicked
    $("body").on "click", "#clear-selected-entity", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedEntity()

    #When the clear groups button is clicked
    $("body").on "click", "#clear-selected-entitys-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedEntitysGroups()

    #When the delete entity button is clicked
    $("body").on "click", "#delete-selected-entity", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"

            deleteEntity window.selected_entity


    #When the delete groups button is clicked
    $("body").on "click", "#delete-selected-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"

            deleteGroups window.selected_groups

    #When the delete properties button is clicked
    $("body").on "click", "#delete-selected-properties", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"

            deleteProperties window.selected_properties

    #When the delete groups button is clicked
    $("body").on "click", "#delete-selected-entitys-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"

            deleteEntityGroupRelations window.selected_entity_group_relations

    $("body").on "click", "#top-selected-entitys-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            
            topEntityGroupRelations window.selected_entity_group_relations

    $("body").on "click", "#up-selected-entitys-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            
            upEntityGroupRelations window.selected_entity_group_relations

    $("body").on "click", "#down-selected-entitys-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            
            downEntityGroupRelations window.selected_entity_group_relations

    $("body").on "click", "#bottom-selected-entitys-groups", (e) ->

        #if it's enabled
        unless $(this).hasClass "disabled"
            
            bottomEntityGroupRelations window.selected_entity_group_relations

toggleChevron = (e) ->
    $(e.target)
        .prev '.panel-heading'
        .find 'i.collapse-indicator'
        .toggleClass 'glyphicon-chevron-down glyphicon-chevron-right'

$getAllParams = () ->
    params = $.param( { 
            selected_entity: window.selected_entity,
            selected_entity_group_relations: window.selected_entity_group_relations, 
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

toggleEntitySelect = (id) ->
    $("tr.selected-entity").removeClass("selected-entity")
    clearSelectedEntitysGroups()

    if window.selected_entity == id
        clearSelectedEntity()

    else
        $("tr#"+id+".entity").addClass "selected-entity"
        window.selected_entity = id + ""
        getEntitysGroups id
        validateEntitySelection()

window.toggleEntitySelect = toggleEntitySelect

clearSelectedEntity = () ->
    $("tr.selected-entity").removeClass "selected-entity"
    window.selected_entity = -1
    window.selected_entitys_max_group_order = -1
    validateEntitySelection()
    getEntitysGroups window.selected_entity

window.clearSelectedEntity = clearSelectedEntity

validateEntitySelection = () ->
    #clear the selected entity's groupsd partial if no entity is selected
    if window.selected_entity < 0
        _html = "<div class='alert alert-info small-font center'>"
        _html += "<i>No Entity selected.</i></div>"
        $("#entitys_groups").html ""
        $("#entitys-groups-alert").html _html
        $("#clear-selected-entity").addClass("disabled")
        $("#delete-selected-entity").addClass("disabled")
    else
        $("#clear-selected-entity").removeClass("disabled")
        $("#delete-selected-entity").removeClass("disabled")
    validateAddGroupsToEntity()
window.validateEntitySelection = validateEntitySelection

deleteEntity = (id) ->
    params = $.param( { 
        selected_entity: id, 
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
        url: "/hub/delete_entity?" + params
        type: 'POST'

    validateEntitySelection()

window.deleteEntity = deleteEntity  

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
        group_sort: window.group_sort } )
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/entity_add_groups?" + params
        type: 'POST'
window.addGroupsToEntity = addGroupsToEntity  

deleteEntityGroupRelations = (relationship_ids) ->
    params = $.param( { 
        selected_entity: window.selected_entity,
        selected_entity_group_relations: relationship_ids, 
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

topEntityGroupRelations = (relationship_ids) ->
    params = $.param( { 
        selected_entity: window.selected_entity,
        selected_entity_group_relations: relationship_ids.sort(), 
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
        selected_entity_group_relations: relationship_ids.sort(), 
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
        selected_entity_group_relations: relationship_ids.sort(), 
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
        selected_entity_group_relations: relationship_ids.sort(), 
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

toggleGroupSelect = (id) ->
    index = $.inArray(id, window.selected_groups)
    if index > -1
        $("tr#"+id+".group").removeClass "selected-group"
        window.selected_groups.splice(index, 1)
    else
        $("tr#"+id+".group").addClass "selected-group"
        window.selected_groups.push(id)
        getGroupsProperties window.selected_groups
    validateGroupSelection()
window.toggleGroupSelect = toggleGroupSelect

validateGroupSelection = () ->
    if window.selected_groups.length > 0
        $("#clear-selected-groups").removeClass("disabled")
        $("#delete-selected-groups").removeClass("disabled")
        clearSelectedEntitysGroups()
    else
        _html = "<div class='alert alert-info small-font center'>"
        _html += "<i>No Group selected.</i></div>"
        $("#groups_properties").html ""
        $("#groups-properties-alert").html _html
        $("#clear-selected-groups").addClass("disabled")
        $("#delete-selected-groups").addClass("disabled")
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

    validateGroupSelection()
window.deleteGroups = deleteGroups

clearSelectedGroups = () ->
    window.selected_groups = []
    $("tr.selected-group").removeClass "selected-group"
    validateGroupSelection()
window.clearSelectedGroups = clearSelectedGroups

togglePropertySelect = (id) ->
    index = $.inArray(id, window.selected_properties)
    if index > -1
        $("tr#"+id+".property").removeClass "selected-property"
        window.selected_properties.splice(index, 1)
    else
        $("tr#"+id+".property").addClass "selected-property"
        window.selected_properties.push(id)
    validatePropertySelection()
window.togglePropertySelect = togglePropertySelect

validatePropertySelection = () ->
    if window.selected_properties.length > 0
        $("#clear-selected-properties").removeClass("disabled")
        $("#delete-selected-properties").removeClass("disabled")
    else
        $("#clear-selected-properties").addClass("disabled")
        $("#delete-selected-properties").addClass("disabled")
    validateAddPropertiesToGroup()
window.validatePropertySelection = validatePropertySelection

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
        property_sort: window.property_sort
        } )
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/group_add_properties?" + params
        type: 'POST'
window.addPropertiesToGroup = addPropertiesToGroup  

deleteProperties = (properties) ->
    params = $.param( { 
        selected_entity: window.selected_entity, 
        selected_groups: window.selected_groups,
        selected_properties: properties,
        group_search: $("input#group_search_field").val(), 
        property_search: $("input#property_search_field").val(), 
        entity_search: $("input#entity_search_field").val(), 
        group_direction: window.group_direction, 
        property_direction: window.property_direction, 
        entity_direction: window.entity_direction, 
        group_sort: window.group_sort, 
        property_sort: window.property_sort, 
        entity_sort: window.entity_sort  
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/delete_properties?" + params
        type: 'POST'

    validatePropertySelection()
window.deleteProperties = deleteProperties

clearSelectedProperties = () ->
    window.selected_properties = []
    $("tr.selected-property").removeClass "selected-property"
    validatePropertySelection()
window.clearSelectedProperties = clearSelectedProperties

toggleEntitysGroupSelect = (id, order) ->
    #if the clicked group is already selected
    id += "" #stringify
    index = $.inArray id, window.selected_entity_group_relations
    if index > -1
        window.selected_entity_group_relations.splice(index, 1)
        $("tr#"+id+".entity_group_relationship").removeClass "selected-entitys-group"
    else
        $("tr#"+id+".entity_group_relationship").addClass "selected-entitys-group"
        window.selected_entity_group_relations.push(id)

    order += "" #stringify
    index = $.inArray order, window.selected_entity_group_orders
    if index > -1
        window.selected_entity_group_orders.splice(index, 1)
    else
        window.selected_entity_group_orders.push order

    validateEntitysGroupSelection()
window.toggleEntitysGroupSelect = toggleEntitysGroupSelect

validateEntitysGroupSelection = () ->
    if window.selected_entity_group_relations.length > 0
        $("#clear-selected-entitys-groups").removeClass("disabled")
        $("#delete-selected-entitys-groups").removeClass("disabled")
        clearSelectedGroups()
    else
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

clearSelectedEntitysGroups = () ->
    window.selected_entity_group_relations = []
    window.selected_entity_group_orders = []
    # window.selected_entitys_max_group_order = -1
    $("tr.selected-entitys-group").removeClass "selected-entitys-group"
    validateEntitysGroupSelection()
window.clearSelectedEntitysGroups = clearSelectedEntitysGroups

getEntitysGroups = (id) ->
    params = $.param( { 
        selected_entity: id, 
        selected_groups: window.selected_groups, 
        group_search: $("input#group_search_field").val(), 
        group_direction: window.group_direction, 
        group_sort: window.group_sort, 
        event: 'entitys_groups'
        } )
    $
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/entitys_groups?" + params
        type: 'POST'
window.getEntitysGroups = getEntitysGroups

getGroupsProperties = (ids) ->
    params = $.param( { 
        selected_groups: ids, 
        selected_properties: window.selected_properties, 
        property_search: $("input#property_search_field").val(), 
        property_direction: window.property_direction, 
        property_sort: window.property_sort 
        } )
    $
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/groups_properties?" + params
        type: 'POST'
window.getGroupsProperties = getGroupsProperties

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

    if window.selected_entity_group_relations.length > 0
        for relationship_id in window.selected_entity_group_relations
            $("tr#"+relationship_id+".entity_group_relationship").addClass "selected-entitys-group"
    else
        $("tr.selected-entitys-group").removeClass "selected-entitys-group"

    if window.selected_properties.length > 0
        for property in window.selected_properties
            $("tr#"+property+".property").addClass "selected-property"
    else
        $("tr.selected-properties").removeClass "selected-properties"
#globalize persistStyling        
window.persistStyling = persistStyling

#Ensure ajaxified pagination buttons on any additions to lists
ajaxPagination = () ->
    #Ajaxify All List Page changes
    $("body").on "click", '.pagination a', (e) ->
        window.entities_page = getParameterByName "entities_page", this.href || "1"
        window.properties_page = getParameterByName "properties_page", this.href || "1"
        window.groups_page = getParameterByName "groups_page", this.href || "1"
        e.preventDefault()
        $.getScript(this.href)
        false
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
        $(documentId).html html

window.hubAlert = hubAlert
