window.selected_properties = [] #list of selected groups
window.selected_egrs = [] #list of selected entity's groupswindow.property_sort = "created_at"
window.property_sort = "created_at"
window.property_direction = "desc"
window.properties_page = "1"

$ ->

    #ajaxify create new form collapse
    $("#new-property-collapse-heading").on "click", (e) ->
        e.preventDefault()

    console.log("hub_property_helpers")
    $("select#role_ids.new-property-roles").select2({
          placeholder: "Roles that see this property...",
        })
    # $("input#create-property").css("margin-top", '15px')

    #on list element click
    $("body").on "click", '.table tr.property', (e) ->
        togglePropertySelect this.id, e.ctrlKey || e.metaKey

    #When the clear properties button is clicked
    $("body").on "click", "#clear-selected-properties", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            clearSelectedProperties()

    #When the delete properties button is clicked
    $("body").on "click", "#delete-selected-properties", (e) ->
        #if it's enabled
        unless $(this).hasClass "disabled"
            deleteProperties window.selected_properties

    #Ajaxify List Sorting
    $('#properties').on 'click', "th a", (e) ->
        window.property_sort = getParameterByName "property_sort", this.href
        window.property_direction = getParameterByName "property_direction", this.href
        params = getPropertyParams()

        #send the request
        $.get "/hub?" + params
        false

    #Every character change in Search field, submit query
    $("input#property_search_field").on 'input', ->
        window.properties_page = "1"
        params = getPropertyParams()
        #send the request
        $.get "/hub?" + params
        false
        # $("input#selected_entity").val window.selected_entity
        # $("#search_group").submit()

#end onLoad function

getPropertyParams = () ->
    params = $.param( { 
            selected_groups: window.selected_groups,
            selected_egrs: window.selected_egrs,
            selected_properties: window.selected_properties,
            property_search: $("input#property_search_field").val(), 
            property_direction: window.property_direction, 
            property_sort: window.property_sort,
            properties_page: window.properties_page,
            event: "property"
            } )
    return params
window.getPropertyParams = getPropertyParams

#Ensure ajaxified pagination buttons on any additions to list
propertyPagination = () ->
    #Ajaxify List Page changes
    $("div#properties").on "click", '.pagination a', (e) ->
        window.properties_page = getParameterByName( "properties_page", this.href ) || "1"
        params = getPropertyParams()
        #send the request
        $.get "/hub?" + params
        false
window.propertyPagination = propertyPagination

#hub property functions
togglePropertySelect = (id, multiSelect) ->
    index = $.inArray(id, window.selected_properties)
    if index > -1
        if window.selected_properties.length > 1 && !multiSelect
            clearSelectedProperties()
            $("tr#"+id+".property").addClass "selected-property"
            window.selected_properties.push(id)
        else
            window.selected_properties.splice(index, 1)
            $("tr#"+id+".property").removeClass "selected-property"
    else if multiSelect
        $("tr#"+id+".property").addClass "selected-property"
        window.selected_properties.push(id)
    else
        clearSelectedProperties()
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
    validateCreateGPR()
window.validatePropertySelection = validatePropertySelection

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

clearPropertyAttributes = () ->
    window.property_sort = "created_at"
    window.property_direction = "desc"
    window.properties_page = "1"
window.clearPropertyAttributes = clearPropertyAttributes