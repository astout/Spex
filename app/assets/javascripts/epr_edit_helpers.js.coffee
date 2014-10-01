

$ ->

    $("body").on "input", "input.epr-formula-text", (e) ->
        _text = $(this).val()
        if _text.length > 0
          $("button#"+this.id+".epr-text-append").removeClass("disabled")
        else
          $("button#"+this.id+".epr-text-append").addClass("disabled")

    $("body").on "click", "button.epr-text-append", (e) ->
        unless $(this).hasClass "disabled"
          _value = $("textarea#"+this.id+".epr-value").val().trim()
          if _value.length > 0
            _text = _value + " " + $("input#"+this.id+".epr-formula-text").val()
          else
            _text = _value + $("input#"+this.id+".epr-formula-text").val()
          $("textarea#"+this.id+".epr-value").val( _text )
          $("input#"+this.id+".epr-formula-text").val("")
        e.preventDefault()
        return false

    $("body").on "click", "button.epr-ref-append", (e) ->
        unless $(this).hasClass "disabled"
          _value = $("textarea#"+this.id+".epr-value").val().trim()
          _text = ""
          if _value.length > 0
            _text = _value + " "
          try
            _text += "{"
            if $("select#"+this.id+".epr-ref-entity").val() == "" + $("input#"+this.id+".epr-ename").data().entityId
              _text += "*"
            else
              _text += $("select#"+this.id+".epr-ref-entity").select2("data").text
            _text += "."
            if $("select#"+this.id+".epr-ref-group").val() == "" + $("input#"+this.id+".epr-gname").data().groupId
              _text += "*"
            else
              _text += $("select#"+this.id+".epr-ref-group").select2("data").text
            _text += "."
            _text += $("select#"+this.id+".epr-ref-property").select2("data").text
            _text += "}"
          catch e
            console.log("error: couldn't parse the dropdown values")

          $("textarea#"+this.id+".epr-value").val(_text)
        e.preventDefault()
        return false

    $("body").on "click", "button.epr-evaluate", (e) ->
      _id = this.id
      _value = $("textarea#"+_id+".epr-value").val()
      console.log("EVALUATING: " + _value)
      params = $.param( {
        value: _value,
        epr: _id
        })
      $.ajax
        url: '/hub/epr_evaluate?' + params
        type: 'GET'
        success: (data, textStatus, jqXHR) ->
          $("input#"+_id+".epr-evaluated-text").val(data)
          console.log("data")
          console.log(data)
          console.log("textStatus")
          console.log(textStatus)
          console.log("jqXHR")
          console.log(jqXHR)
      e.preventDefault()
      return false

    $("body").on "click", "button.epr.calculator", (e) ->
      console.log("id: " + this.id + " button: " + this.innerText + " value: " + this.value )
      _value = $("textarea#"+this.id+".epr-value").val($("textarea#"+this.id+".epr-value").val().trim() + " " + this.value)
      e.preventDefault()
      return false
#end startup

selectize_all = () ->
  do_selectize("entity")
  do_selectize("group")
  do_selectize("property")
  $("select.epr-roles").select2({
    placeholder: "Roles that see this property...",
    })
window.selectize_all = selectize_all

#use the select2 module on the dropdown field for each model
do_selectize = (_model) ->

  console.log("doing " + _model)

  #if the model is property, if the value is valid,
  #enable the append button
  if _model == "property"
    #initialize select2 on this model's select field
    $("select.epr-ref-"+_model).select2({
      placeholder: "Choose a " + _model + "...",
      allowClear: true
    })
    $("select.epr-ref-property").on "change", (e) ->
      console.log("property: " + $(this).val())
      console.log("this id: " + this.id)
      _val = $(this).val()
      if _val.length > 0
        $("button#"+this.id+".epr.ref-append").removeClass("disabled")
      else
        $("button#"+this.id+".epr.ref-append").addClass("disabled")

  #if the model is group, get the appropriate eprs for the currently
  #selected entity and group
  if _model == "group"
    #initialize select2 on this model's select field
    $("select.epr-ref-"+_model).select2({
      placeholder: "Choose a " + _model + "...",
      allowClear: true
    })
    $("select.epr-ref-group").on "change", (e) ->
      console.log("epr id: " + this.id)
      console.log("group id: " + $(this).val())
      params = $.param( { 
        epr_ref_entity: $("select#"+this.id+".epr-ref-entity").val(),
        epr_ref_group: $(this).val(),
        current_epr: this.id
        } )
      #send the request to add the selected groups to the selected entity
      console.log(params)
      $.ajax 
        url: "/hub/epr_ref_update?" + params
        type: 'GET'

  #if the model is entity, clear the selected group, and get the
  #groups for the selected entity
  if _model == "entity"
    #initialize select2 on this model's select field
    $("select.epr-ref-"+_model).select2({
      placeholder: "Choose an " + _model + "...",
      allowClear: true
    })
    $("select.epr-ref-entity").on "change", (e) ->
      console.log("epr id: " + this.id)
      try
        console.log("entity text: " + $(this).select2('data').text)
      catch e
        # ...
      console.log("entity id: " + $(this).val())
      params = $.param( { 
        epr_ref_entity: $(this).val(),
        epr_ref_group: -1,
        current_epr: this.id
        } )
      $
      #send the request to add the selected groups to the selected entity
      console.log(params)
      $.ajax 
        url: "/hub/epr_ref_update?" + params
        type: 'GET'
  $("button.epr-ref-"+_model).on "click", (e) ->
      $("div#s2id_"+this.id+".select2-container.epr-ref-"+_model).select2("open")
      e.preventDefault()
      return false