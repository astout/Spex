# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.epr_page = "1"
window.epr_direction = "desc"
window.epr_sort = "updated_at"
window.epr_search = ""

$ ->

    if $('body').hasClass "query"

        #Every character change in Search field, submit query
        $("input#epr_search_field").on 'input', ->
            window.epr_page = "1"
            params = get_epr_params()
            #send the request
            $.get "/query?" + params
            false

get_epr_params = () ->
    params = $.param( {
        epr_search: $("input#epr_search_field").val(), 
        epr_direction: window.epr_direction, 
        epr_sort: window.epr_sort,  
        epr_page: window.epr_page,
        event: "epr"
    })
    return params