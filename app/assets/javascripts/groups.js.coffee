# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

    if $("form#new_group").length > 0
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

get_group_params = () ->
    params = $.param( {
        group_search: $("input#group_search").val(), 
        groups_page: "1",
        event: "group"
    })
    return params

NewGroupValidation = () ->
    name = $("input#group_name").val()
    label = $("input#group_label").val()

    if name.length > 0
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
    $("input[type=submit]#create-group").removeClass 'disabled'

invalid = () ->
    $("input[type=submit]#create-group").addClass 'disabled'