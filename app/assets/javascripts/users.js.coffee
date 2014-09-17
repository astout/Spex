# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  console.log("here")

  if $("body").hasClass("edit-user")
    console.log("hell0?")
    $("select#set_role").select2({
      placeholder: "Choose a Role...",
      allowClear: false
    })
    $("select#set_role").on "change", (e) ->
      _val = $(this).val()
      console.log("value: " + _val)
      $("input#role_id").val(_val)

  if $("body").hasClass("users-index")
    #Every character change in Search field, submit query
      $("body").on "input", "input#user_search_field", (e) ->
          console.log $(this).val()
          params = get_user_params()
          #send the request
          $.get "users?" + params
          false

get_user_params = () ->
    params = $.param( {
        user_search: $("input#user_search_field").val(), 
        users_page: "1",
        event: "user"
    })
    return params