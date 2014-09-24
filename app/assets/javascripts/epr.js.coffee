# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



$ ->

    if $('body').hasClass "query"

      window.epr_page = "1"
      window.epr_direction = "desc"
      window.epr_sort = "updated_at"
      window.epr_search = ""
      window.view_id = $("input#epr-r").val()

      #Every character change in Search field, submit query
      $("body").on 'input', "input#epr_search_field", (e) ->
          window.epr_page = "1"
          params = get_epr_params()
          #send the request
          $.get "/query?" + params
          false
      $("select.roles").select2({
        placeholder: "View As...",
      })

      $("select.roles").on "change", (e) ->
        console.log("role: " + $(this).val())
        window.view_id = $(this).val()
        params = get_epr_params()
        $.get "/query?" + params

get_epr_params = () ->
    params = $.param( {
        epr_search: $("input#epr_search_field").val(), 
        epr_direction: window.epr_direction, 
        epr_sort: window.epr_sort,  
        epr_page: window.epr_page,
        view_id: window.view_id,
        event: "epr"
    })
    return params