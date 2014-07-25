# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

    if $("form#new_group").length > 0
        $("input#group_name, input#group_label").on "input", ->
            NewGroupValidation()
        NewGroupValidation()

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