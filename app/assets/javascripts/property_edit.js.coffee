$ ->

    console.log("property edit js loaded")

    $("body").on "input", "input.property-formula-text", (e) ->
        _text = $(this).val()
        if _text.length > 0
          $("button#"+this.id+".property-text-append").removeClass("disabled")
        else
          $("button#"+this.id+".property-text-append").addClass("disabled")

    $("body").on "click", "button.property-text-append", (e) ->
        unless $(this).hasClass "disabled"
          _value = $("textarea#"+this.id+".property.default_value").val().trim()
          if _value.length > 0
            _text = _value + " " + $("input#"+this.id+".property-formula-text").val()
          else
            _text = _value + $("input#"+this.id+".property-formula-text").val()
          $("textarea#"+this.id+".property.default_value").val( _text )
          $("input#"+this.id+".property-formula-text").val("")
        e.preventDefault()
        return false

    $("body").on "click", "button.property.ref-append", (e) ->
        unless $(this).hasClass "disabled"
          _value = $("textarea#"+this.id+".property.default_value").val().trim()
          _text = ""
          if _value.length > 0
            _text = _value + " "
          try
            temp = "{"
            if $("select#"+this.id+".property-ref-entity").val() == ""
              temp += "*"
            else
              temp += $("select#"+this.id+".property-ref-entity").select2("data").text
            temp += "."
            if $("select#"+this.id+".property-ref-group").val() == ""
              temp += "*"
            else
              temp += $("select#"+this.id+".property-ref-group").select2("data").text
            temp += "."
            temp += $("select#"+this.id+".property-ref-property").select2("data").text
            temp += "}"
            _text += temp
          catch error
            console.log("error: couldn't parse the dropdown values")

          $("textarea#"+this.id+".property.default_value").val(_text)
        e.preventDefault()
        return false

    $("body").on "click", "button.property-evaluate", (e) ->
      _id = this.id
      _value = $("textarea#"+_id+".property.default_value").val()
      console.log("EVALUATING: " + _value)
      params = $.param( {
        value: _value,
        property: _id
        })
      $.ajax
        url: '/hub/property_evaluate?' + params
        type: 'GET'
        success: (data, textStatus, jqXHR) ->
          $("input#"+_id+".property-evaluated-text").val(data)
          console.log("data")
          console.log(data)
          console.log("textStatus")
          console.log(textStatus)
          console.log("jqXHR")
          console.log(jqXHR)
      e.preventDefault()
      return false

    $("body").on "click", "button.property.calculator", (e) ->
      console.log("id: " + this.id + " button: " + this.innerText + " value: " + this.value )
      _value = $("textarea#"+this.id+".property.default_value").val($("textarea#"+this.id+".property.default_value").val().trim() + " " + this.value)
      e.preventDefault()
      return false

    $("body").on "click", "button#new.property.copy", (e) ->
      e.preventDefault()
      console.log("id: " + $("select.property.copy_from").val() + " copy")
      _id = $("select.property.copy_from").val()
      params = $.param( { 
        copy_id: _id
        } )
      $.ajax 
        url: "/hub/property_copy_fields?" + params
        type: 'GET'
      return false

#end startup

properties_selectize_all = () ->
  do_selectize("entity")
  do_selectize("group")
  do_selectize("property")
  $("select.property.role_ids").select2({
    placeholder: "Roles that see this property...",
    })
  $("select.property.copy_from").select2({
    placeholder: "Copy fields from...",
    allowClear: true
    })
window.properties_selectize_all = properties_selectize_all

#use the select2 module on the dropdown field for each model
do_selectize = (_model) ->

  console.log("selectizing " + _model)

  #if the model is property, if the value is valid,
  #enable the append button
  if _model == "property"
    #initialize select2 on this model's select field
    $("select.property-ref-"+_model).select2({
      placeholder: "Choose a " + _model + "...",
      allowClear: true
    })
    $("select.property-ref-property").on "change", (e) ->
      console.log("property: " + $(this).val())
      console.log("this id: " + this.id)
      _val = $(this).val()
      if _val.length > 0
        $("button#"+this.id+".property.ref-append").removeClass("disabled")
      else
        $("button#"+this.id+".property.ref-append").addClass("disabled")

  #if the model is group, get the appropriate propertys for the currently
  #selected entity and group
  if _model == "group"
    #initialize select2 on this model's select field
    $("select.property-ref-"+_model).select2({
      placeholder: "Choose a " + _model + "...",
      allowClear: true
    })
    $("select.property-ref-group").on "change", (e) ->
      console.log("property id: " + this.id)
      console.log("group id: " + $(this).val())
      params = $.param( { 
        property_ref_entity: $("select#"+this.id+".property-ref-entity").val(),
        property_ref_group: $(this).val(),
        current_property: this.id
        } )
      #send the request to add the selected groups to the selected entity
      console.log(params)
      $.ajax 
        url: "/hub/property_ref_update?" + params
        type: 'GET'

  #if the model is entity, clear the selected group, and get the
  #groups for the selected entity
  if _model == "entity"
    #initialize select2 on this model's select field
    $("select.property-ref-"+_model).select2({
      placeholder: "Choose an " + _model + "...",
      allowClear: true
    })
    $("select.property-ref-entity").on "change", (e) ->
      console.log("property id: " + this.id)
      try
        console.log("entity text: " + $(this).select2('data').text)
      catch e
        # ...
      console.log("entity id: " + $(this).val())
      params = $.param( { 
        property_ref_entity: $(this).val(),
        property_ref_group: -1,
        current_property: this.id
        } )
      $
      #send the request to add the selected groups to the selected entity
      console.log(params)
      $.ajax 
        url: "/hub/property_ref_update?" + params
        type: 'GET'
  $("button.property-ref-"+_model).on "click", (e) ->
      $("div#s2id_"+this.id+".select2-container.property-ref-"+_model).select2("open")
      e.preventDefault()
      return false