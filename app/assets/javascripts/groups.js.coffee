# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

    if $("form#new_group").length > 0 || $("form[id^=edit_group]").length > 0
        console.log("edit")
        $("input#group_name, input#group_label").on "input", ->
            NewGroupValidation()
        NewGroupValidation()

    if $("body").hasClass("groups-index")
      #Every character change in Search field, submit query
      $("body").on "input", "input#group_search", (e) ->
          console.log $(this).val()
          params = get_group_params()
          #send the request
          $.get "groups?" + params
          false

      $("body").on "click", "span.delete", (e) ->
          deleteModal(this.id)
          # $("#delete-confirm").modal("show");
          console.log "delete clicked"

      $("body").on "click", "button#btn-delete-confirm", (e) ->
          console.log "confirm delete"
          params = $.param( {
              id: $("span.delete-group-id")[0].id
              })
          $.ajax
              url: "/groups/confirm_delete?" + params
              type: 'POST'

deleteModal = (_id) ->
    if _id.length < 1
        return false
    params = $.param( { 
      id: _id,
      } )
    $.ajax 
      url: "/groups/delete_request?" + params
      type: 'POST' 

get_group_params = () ->
    params = $.param( {
      group_search: $("input#group_search").val(), 
      groups_page: "1",
      event: "group"
    })
    return params

NewGroupValidation = () ->
    console.log("validating")
    name = $("input#group_name").val()
    label = $("input#group_label").val()

    rx = /^[A-Za-z0-9]+[A-Za-z0-9\-\_]*[A-Za-z0-9]+$/

    if name.length > 0 && rx.test(name)
      unless $("span#group_name").hasClass "valid"
        $("span#group_name").addClass "valid"
      valid()
    else
      $("span#group_name").removeClass "valid"
      invalid()

    unless $("span#group_label").hasClass "valid"
      $("span#group_label").addClass "valid"
window.NewGroupValidation = NewGroupValidation

valid = () ->
    $("span#group_name, span#group_label").addClass "valid"
    $("input[type=submit].group").removeClass 'disabled'
    #explicitly submit the new group form on enter key press
    $("body").on "keydown", "input.group", (e) ->
      console.log("valid input")
      if e.keyCode == 13
        console.log("enter preseed")
        $("form#new_group").submit()
        $("form[id^=edit_group]").submit()
        return false

invalid = () ->
    $("input[type=submit].group").addClass 'disabled'
    $("body").on "keydown", "input.group", (e) ->
      console.log("invalid input")
      if e.keyCode == 13
        console.log("enter preseed")
        e.preventDefault()
        return false