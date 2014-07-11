#entity property relationship functions

#epr
window.selected_entity_property_relations = [] #list of selected group's properties
window.selected_entitys_group_max_property_order = -1

$ ->

    $("td[id^=edit-entity-property-relation]").on "click", "a", (e) ->
        alert("hello?")
        e.preventDefault()

    #On list element click
    $("body").on "click", '.table tr.entity_property_relationship', (e) ->
        #get the group id
        toggleEntityPropertySelect this.id, $(this).data().order

#end onLoad function

getEntitysProperties = (relationship_ids) ->
    params = $.param( { 
        selected_entity_group_relations: relationship_ids
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
window.getEntitysProperties = getEntitysProperties