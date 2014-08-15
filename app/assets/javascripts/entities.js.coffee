# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

    if $("body").hasClass "report"

      $(".trueValue").hide();

      $("td.property-value").hover (e) ->
        _this = this
        openTrueValue _this 
        e.preventDefault()

    if $("form#new_entity").length > 0
      $("input#entity_name, input#entity_label, input#entity_img").on "input", ->
          NewEntityValidation()
      NewEntityValidation()

openTrueValue = (element) ->
  openForm = $(element).hasClass('openForm')
  open = []
  if openForm 
    id = element.id
    $(element).removeClass('openForm')
    $('#'+id+".trueValue").delay(300).slideUp()
  else
    open = $('td.property-value.openForm')
    if( open.length == 1)
        id = open[0].id
        open.removeClass('openForm')
        $('#'+id+'.trueValue').delay(300).slideUp()
    $(element).addClass('openForm')
    id = element.id
    $('#'+id+'.trueValue').slideDown()


NewEntityValidation = () ->
    name = $("input#entity_name").val()
    label = $("input#entity_label").val()
    image = $("input#entity_img").val()

    if name.length > 0
        unless $("span#entity_name").hasClass "valid"
            $("span#entity_name").addClass "valid"
        valid()
    else
        $("span#entity_name").removeClass "valid"
        invalid()

    unless $("span#entity_label").hasClass "valid"
        $("span#entity_label").addClass "valid"
    unless $("span#entity_img").hasClass "valid"
        $("span#entity_img").addClass "valid"
window.NewEntityValidation = NewEntityValidation

valid = () ->
    $("span#entity_name, span#entity_img, span#entity_label").addClass "valid"
    $("input[type=submit]#create-entity").removeClass 'disabled'

invalid = () ->
    $("input[type=submit]#create-entity").addClass 'disabled'
