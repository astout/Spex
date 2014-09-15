# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require epr_edit_helpers


$ ->

    if $("body").hasClass "report"

      selectize_all()

      hideDisabledFields()

      registerHiddenRows()

      $('.popover-markup>.trigger').popover({
          placement: "top",
          trigger: "click",
          html: true,
          title: () ->
              return $(this).parent().find('.head').html();
          ,
          content: () ->
              return $(this).parent().find('.content').html();
          
      })

      $("body").on("click", "button#submit", (e) ->
        alert("submitted")
      )
      
      $("select.roles").select2({
        placeholder: "View As...",
      })

      $("select.roles").on "change", (e) ->
        console.log("role: " + $(this).val())
        console.log("entity: " + $(this).data().entity)
        console.log("this id: " + this.id)
        params = $.param( { 
          id: $(this).data().entity,
          view_id: $(this).val(),
          } )
        $.ajax 
          url: "/entities/show?" + params
          type: 'POST'

    if $("form.new_entity").length > 0 || $("form.edit_entity").length > 0
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
    # open = $('td.property-value.openForm')
    open = $('tr.epr-row.openForm')
    if( open.length == 1)
        id = open[0].id
        open.removeClass('openForm')
        $('#'+id+'.trueValue').delay(300).slideUp()
    $(element).addClass('openForm')
    id = element.id
    $('#'+id+'.trueValue').slideDown()

closeAllOpenForms = () ->
  $(".openForm").removeClass("openForm")
  $(".trueValue").slideUp()
window.closeAllOpenForms = closeAllOpenForms

hideDisabledFields = () ->
  $("input[disabled='disabled']").hide()
  $("label[for='entity_property_relationship_entity']").hide()
  $("label[for='entity_property_relationship_group']").hide()
  $("label[for='entity_property_relationship_property']").hide()
  $("label[for='entity_property_relationship_position']").hide()
window.hideDisabledFields = hideDisabledFields

registerHiddenRows = () ->
  $(".trueValue").hide();

  $("body").on "click", "a.editable.trigger", (e) ->
    openTrueValue this
    e.preventDefault()
    return false

  # $("tr.epr-row").hover (e) ->
  #   openTrueValue this
  #   e.preventDefault()

  # $("td.property-value").hover (e) ->
  #   _this = this
  #   openTrueValue _this 
  #   e.preventDefault()
window.registerHiddenRows = registerHiddenRows

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
    $("input[type=submit]").removeClass 'disabled'

invalid = () ->
    $("input[type=submit]").addClass 'disabled'
