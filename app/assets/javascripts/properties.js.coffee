# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

    console.log("properties.js")

    if $("form#new_property").length > 0 || $("form.edit_property").length > 0
        $("input#property_name, 
            input#property_default_label, 
            input#property_units,
            input#property_units_short,
            input#property_default_value").on "input", ->
            NewPropertyValidation()
        NewPropertyValidation()

        $("body").on "change", "select#role_ids", (e) ->
            $("input#property_role_ids").val($(this).val())


NewPropertyValidation = () ->
    name = $("input#property_name").val()
    label = $("input#property_default_label").val()
    units = $("input#property_units").val()
    units_short = $("input#property_units_short").val()
    value = $("input#property_default_value").val()
    roles = $("select#role_ids.new-property-roles").val()
    # visibility = $("input#property_default_visibility").val()

    _valid = true

    if name.length > 0
        unless $("span#property_name").hasClass "valid"
            $("span#property_name").addClass "valid"
    else
        $("span#property_name").removeClass "valid"
        _valid = false

    rx = /^\d+$/
    # if rx.test visibility.trim()
    #     unless $("span#property_default_visibility").hasClass "valid"
    #         $("span#property_default_visibility").addClass "valid"
    # else
    #     $("span#property_default_visibility").removeClass "valid"
    #     _valid = false

    unless $("span#property_default_label").hasClass "valid"
        $("span#property_default_label").addClass "valid"
    unless $("span#property_units").hasClass "valid"
        $("span#property_units").addClass "valid"
    unless $("span#property_units_short").hasClass "valid"
        $("span#property_units_short").addClass "valid"
    unless $("span#property_default_value").hasClass "valid"
        $("span#property_default_value").addClass "valid"
    unless $("span#property_roles").hasClass "valid"
        $("span#property_roles").addClass "valid"

    if _valid 
        valid()
    else 
        invalid()
window.NewPropertyValidation = NewPropertyValidation

valid = () ->
    $("span#property_name, 
        span#property_units, 
        span#property_default_label, 
        span#property_default_value,
        span#property_units_short
        ").addClass "valid"
    $("input[type=submit]#create-property").removeClass 'disabled'

invalid = () ->
    $("input[type=submit]#create-property").addClass 'disabled'