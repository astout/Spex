# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://coffeescript.org/

# #= require property_edit

$ ->

referenceChange = (element) ->
  _data = $(element).data()
  console.log element
  console.log "id: " + element.id
  console.log "data: "
  console.log _data
  console.log "value: " + $(element).val()
  if _data.reference == "entity"
    params = $.param( {
      property_ref_entity: $(element).val(),
      property_ref_group: -1,
      current_property: element.id
      } )
    #TODO: Move this to properties controller
    $.get "/hub/property_ref_update?" + params
  if _data.reference == "group"
    params = $.param( {
      property_ref_entity: $("select#"+element.id+".property-ref.entity").val(),
      property_ref_group: $(element).val(),
      current_property: element.id
      } )
    #TODO: Move this to properties controller
    $.get "/hub/property_ref_update?" + params

window.referenceChange = referenceChange

referenceSelectize = (element) ->
  console.log("selectize: " + $(element).data().reference)
  $(element).select2( {
      allowClear: true,
      matcher: getMatcherFunction()
    })
window.referenceSelectize = referenceSelectize

copyFrom = (element) ->
  e.preventDefault()
  console.log("id: " + $("select.property.copy_from").val() + " copy")
  _id = $("select.property.copy_from").val()
  $.get "/hub/property_copy_fields?" + $.param( { copy_id: _id } )
  return false
window.copyFrom = copyFrom  

getMatcherFunction = () ->
  return (term, text, opt) ->
    words = term.split(" ")
    _result = false;
    for word in words
      if opt.data().search.toUpperCase().indexOf(word.toUpperCase())>=0
        _result = true
      else
        _result = false
        break
    return _result
window.getMatcherFunction = getMatcherFunction

  # console.log("property id: " + this.id)
  # try
  #   console.log("entity text: " + $(this).select2('data').text)
  # catch e
  #   # ...
  # console.log("entity id: " + $(this).val())
  # params = $.param( { 
  #   property_ref_entity: $(this).val(),
  #   property_ref_group: -1,
  #   current_property: this.id
  #   } )
  # $
  # #send the request to add the selected groups to the selected entity
  # console.log(params)
  # $.ajax 
  #   url: "/hub/property_ref_update?" + params
  #   type: 'GET'
  

#     console.log("properties.js")

#     if $("form#new_property").length > 0 || $("form.edit_property").length > 0
#         $("input.property.name, 
#             input.property.default_label, 
#             input.property.units,
#             input.property.units_short,
#             input.property.default_value").on "input", ->
#               NewPropertyValidation(this.id)

#         $("body").on "keyup", "input.property.name", (e) ->
#           if e.keyCode == 32 #spacebar pressed
#             # e.preventDefault()
#             # $(this).val($(this).val() + "_")
#             $(this).val($(this).val().replace(" ", "_"))
#             NewPropertyValidation(this.id)
#             # return false

#         window.properties_selectize_all()
#         NewPropertyValidation($("input.property.name")[0].id)

#         # $("body").on "change", "select.property.role_ids", (e) ->
#         #     _id = "" + this.id
#         #     $("input#"+_id+".property.role_ids").data().roleIds = $(this).select2("val")
#         #     $("input#"+_id+".property.role_ids").val($(this).select2("val"))
        

#         $("form").on "keypress", (e) ->
#           if e.keyCode == 13 && $("input.submit").hasClass("disabled")
#             return false

#         $("body").on "blur", "input.property.name", (e) ->
#           if $("input#"+this.id+".property.default_label").val().length < 1
#             _val = $(this).val()
#             a = _val.split("_")

#             if a.length > 3
#               a.forEach(capitalizeFirstElement)
#             else
#               a.forEach(capitalizeEachElement)

#             _val = a.join(" ")

#             $("input#" + this.id + ".property.default_label").val(_val)
          
    
#     if $("body").hasClass("properties")
#       #Every character change in Search field, submit query
#       $("body").on "input", "input#property_search", (e) ->
#           console.log $(this).val()
#           params = get_property_params()
#           #send the request
#           $.get "properties?" + params
#           false

#       $("body").on "click", "span.delete", (e) ->
#           console.log("delete clicked")
#           deleteModal(this.id)
#           # $("#delete-confirm").modal("show");
#           console.log "delete clicked"

#       $("body").on "click", "button#btn-delete-confirm", (e) ->
#           console.log "confirm delete"
#           params = $.param( {
#               id: $("span.delete-property-id")[0].id
#               })
#           $.ajax
#               url: "/properties/confirm_delete?" + params
#               type: 'POST'


# capitalize = (string) ->
#   if typeof(string) != "string"
#     return string
#   if string.length > 0
#     string = string[0].toUpperCase() + string.slice(1)
#   return string
# #end capitalize(string)

# capitalizeFirstElement = (element, index, array) ->
#   if index == 0
#     array[index] = capitalize(element)
# #end capitalizeFirstElements(element, index, array)

# capitalizeEachElement = (element, index, array) ->
#   preps = ["a", "the", "of", "per"]
#   if index == 0 || preps.indexOf(element) < 0
#     array[index] = capitalize(element)
# #end capitalizeEachElements(element, index, array)

# deleteModal = (_id) ->
#     if _id.length < 1
#         return false
#     params = $.param( { 
#       id: _id,
#       } )
#     $.ajax 
#       url: "/properties/delete_request?" + params
#       type: 'POST' 

# get_property_params = () ->
#     params = $.param( {
#         property_search: $("input#property_search").val(), 
#         properties_page: "1",
#         event: "property"
#     })
#     return params


# NewPropertyValidation = (_id) ->
#     name = $("input#"+_id+".property.name").val()
#     label = $("input#"+_id+".property.default_label").val()
#     units = $("input#"+_id+".property.units").val()
#     units_short = $("input#"+_id+".property.units_short").val()
#     value = $("input#"+_id+".property.default_value").val()
#     roles = $("select#"+_id+".property.role_ids").val()
#     # visibility = $("input#property_default_visibility").val()

#     _valid = true

#     rx = /^[A-Za-z0-9]+[A-Za-z0-9\-\_]*[A-Za-z0-9]+$/

#     if name.length > 1 && rx.test(name)
#         unless $("span#"+_id+".property.name").hasClass "valid"
#             $("span#"+_id+".property.name").addClass "valid"
#     else
#         $("span#"+_id+".property.name").removeClass "valid"
#         _valid = false

#     # if rx.test visibility.trim()
#     #     unless $("span#property_default_visibility").hasClass "valid"
#     #         $("span#property_default_visibility").addClass "valid"
#     # else
#     #     $("span#property_default_visibility").removeClass "valid"
#     #     _valid = false

#     unless $("span#"+_id+".property.default_label").hasClass "valid"
#         $("span#"+_id+".property.default_label").addClass "valid"
#     unless $("span#"+_id+".property.units").hasClass "valid"
#         $("span#"+_id+".property.units").addClass "valid"
#     unless $("span#"+_id+".property.units_short").hasClass "valid"
#         $("span#"+_id+".property.units_short").addClass "valid"
#     unless $("span#"+_id+".property.default_value").hasClass "valid"
#         $("span#"+_id+".property.default_value").addClass "valid"
#     unless $("span#"+_id+".property.role_ids").hasClass "valid"
#         $("span#"+_id+".property.role_ids").addClass "valid"

#     if _valid 
#         valid(_id)
#     else 
#         invalid(_id)
# window.NewPropertyValidation = NewPropertyValidation

# valid = (_id) ->
#     $("span#"+_id+".property.name, 
#         span#"+_id+".property.units, 
#         span#"+_id+".property.default_label, 
#         span#"+_id+".property.default_value,
#         span#"+_id+".property.units_short
#         ").addClass "valid"
#     $("input#"+_id+".submit.property").removeClass 'disabled'

# invalid = (_id) ->
#     $("input#"+_id+".property.submit").addClass 'disabled'