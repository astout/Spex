# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require epr_edit_helpers


$ ->

    if $("body").hasClass "entities-index"

      #if there's an alert on the page, make it fade out
      # delay 3000, -> 
      #   $("div.alert").fadeOut(1500)


      #Every character change in Search field, submit query
      $("body").on "input", "input#entity_search_field", (e) ->
          console.log $(this).val()
          params = get_entity_params()
          #send the request
          $.get "entities?" + params
          false

      $("body").on "click", "span.delete", (e) ->
          deleteModal(this.id)
          console.log "delete clicked"

      $("body").on "click", "button#btn-delete-confirm", (e) ->
          console.log "confirm delete"
          params = $.param( {
              id: $("span.delete-entity-id")[0].id
              })
          $.ajax
              url: "/entities/confirm_delete?" + params
              type: 'POST'

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

      $("body").on "click", "span#print_view", (e) ->
        params = $.param( {
          e: $(this).data().entity,
          v: $(this).data().view
          } )
        url = "print?" + params
        print = window.open(url, '_blank');
        # $.ajax
        #   url: "print?" + params
        #   type: 'GET'

    if $("form.new_entity").length > 0 || $("form.edit_entity").length > 0
      $("input#entity_name, input#entity_label, input#entity_img").on "input", ->
          NewEntityValidation()
      NewEntityValidation()

delay = (ms, func) ->
  setTimeout func, ms

deleteModal = (_id) ->
    if _id.length < 1
        return false
    params = $.param( { 
      id: _id,
      } )
    $.ajax 
      url: "/entities/delete_request?" + params
      type: 'POST'

get_entity_params = () ->
    params = $.param( {
        entity_search: $("input#entity_search_field").val(), 
        entities_page: "1",
        event: "entity"
    })
    return params

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

    rx = /^[A-Za-z0-9]+[A-Za-z0-9\-\_]*[A-Za-z0-9]+$/

    if name.length > 0 && rx.test(name)
        unless $("span#entity_name").hasClass "valid"
            $("span#entity_name").addClass "valid"
        valid()
    else
        $("span#entity_name").removeClass "valid"
        invalid()

    unless $("span#entity_label").hasClass "valid"
        $("span#entity_label").addClass "valid"
window.NewEntityValidation = NewEntityValidation

valid = () ->
    $("span#entity_name, span#entity_label").addClass "valid"
    $("input[type=submit]").removeClass 'disabled'
    $("body").on "keydown", "input.entity", (e) ->
      console.log "enter valid"
      if e.keyCode == 13
        $("form#new_entity").submit()

invalid = () ->
    $("input[type=submit]").addClass 'disabled'
    $("body").on "keydown", "input.entity", (e) ->
      console.log "enter invalid"
      if e.keyCode == 13
        e.preventDefault()
        return false
