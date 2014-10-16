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
#end onLoad

delay = (ms, func) ->
  setTimeout func, ms

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