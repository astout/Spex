# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  if $("body").hasClass("edit-user") || $("body").hasClass("signup")
    console.log("hell0?")
    $("select#role_id").select2({
      placeholder: "Choose a Role...",
      allowClear: false
    })
    # $("select#set_role").on "change", (e) ->
    #   _val = $(this).val()
    #   console.log("value: " + _val)
    #   $("input#role_id").val(_val)

  if $("body").hasClass("users-index")
    #Every character change in Search field, submit query
      $("body").on "input", "input#user_search", (e) ->
          console.log $(this).val()
          params = get_user_params()
          #send the request
          $.get "users?" + params
          false

      $("body").on "click", "span.delete", (e) ->
          console.log("delete clicked")
          deleteModal(this.id)
          # $("#delete-confirm").modal("show");
          console.log "delete clicked"

      $("body").on "click", "button#btn-delete-confirm", (e) ->
          console.log "confirm delete"
          params = $.param( {
              id: $("span.delete-user-id")[0].id
              })
          $.ajax
              url: "/users/confirm_delete?" + params
              type: 'POST'

deleteModal = (_id) ->
    if _id.length < 1
        return false
    params = $.param( { 
      id: _id,
      } )
    $.ajax 
      url: "/users/delete_request?" + params
      type: 'POST' 

get_user_params = () ->
    params = $.param( {
        user_search: $("input#user_search").val(), 
        users_page: "1",
        event: "user"
    })
    return params