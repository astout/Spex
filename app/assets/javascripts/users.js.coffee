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