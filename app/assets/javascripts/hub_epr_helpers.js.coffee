#entity property relationship functions

#epr variables
window.selected_epr_orders = []
window.selected_eprs = [] #list of selected group's properties
window.selected_epr_max_order = -1

$ ->

    if $('body').hasClass "hub"

        #On list element click
        $("body").on "click", '.table tr.epr', (e) ->
            #toggle the selection
            toggleEPRselect this.id, $(this).data().order, e.metaKey || e.ctrlKey

        $("body").on "click", "td.edit-epr-trigger", (e) ->
            toggleEPRform this
            e.preventDefault()

        $("body").on "click", "#top-selected-eprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                topEPRs window.selected_eprs

        $("body").on "click", "#up-selected-eprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                upEPRs window.selected_eprs

        $("body").on "click", "#down-selected-eprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                downEPRs window.selected_eprs

        $("body").on "click", "#bottom-selected-eprs", (e) ->
            #if it's enabled
            unless $(this).hasClass "disabled"
                bottomEPRs window.selected_eprs

        $("body").on "click", "#clear-selected-eprs", (e) ->
            unless $(this).hasClass "disabled"
                closeAllEPRforms()
                clearSelectedEPRs()

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
                _text += $("select#"+this.id+".epr-ref-entity").select2("data").text
                _text += "."
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
            value: _value
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

        $("body").on "click", "button.epr-math", (e) ->
          console.log("id: " + this.id + " button: " + this.innerText + " value: " + this.value )
          _value = $("textarea#"+this.id+".epr-value").val($("textarea#"+this.id+".epr-value").val().trim() + " " + this.value)
          e.preventDefault()
          return false


#end onLoad function

selectize_all = () ->
  do_selectize("entity")
  do_selectize("group")
  do_selectize("property")
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
        $("button#"+this.id+".epr-ref-append").removeClass("disabled")
      else
        $("button#"+this.id+".epr-ref-append").addClass("disabled")

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
      $
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

toggleEPRform = ( element ) ->
  openForm = $(element).hasClass('openForm')
  open = []
  if openForm 
      id = element.id
      $(element).removeClass('openForm')
      $('#'+id+".edit-epr-form").animate({ height: 'toggle', opacity: 'toggle'}, 'slow')
  else
      open = $('td.edit-epr-trigger.openForm')
      if( open.length == 1)
          id = open[0].id
          open.removeClass('openForm')
          $('#'+id+'.edit-epr-form').animate({ height: 'toggle', opacity: 'toggle'}, 'slow')
      $(element).addClass('openForm')
      id = element.id
      $('#'+id+'.edit-epr-form').slideDown()

closeAllEPRforms = () ->
  open = $('td.edit-epr-trigger.openForm')
  for element in open 
      $("#"+element.id+".edit-epr-form").animate({ height: 'toggle', opacity: 'toggle'}, 'slow')
  open.removeClass('openForm')
window.closeAllEPRforms = closeAllEPRforms

toggleEPRselect = (id, order, multiSelect) ->
    #if the clicked property is already selected
    id += "" #stringify
    index = $.inArray id, window.selected_eprs
    if index > -1
        if window.selected_eprs.length > 1 && !multiSelect
            clearSelectedEPRs()
            $("tr#"+id+".epr").addClass "selected-epr"
            window.selected_eprs.push(id)
        else
            window.selected_eprs.splice(index, 1)
            $("tr#"+id+".epr").removeClass "selected-epr"
    else if multiSelect
        $("tr#"+id+".epr").addClass "selected-epr"
        window.selected_eprs.push(id)
    else
        clearSelectedEPRs()
        $("tr#"+id+".epr").addClass "selected-epr"
        window.selected_eprs.push(id)

    order += "" #stringify
    index = $.inArray order, window.selected_epr_orders
    if index > -1
        window.selected_epr_orders.splice(index, 1)
    else
        window.selected_epr_orders.push order

    validateEPRselection()
window.toggleEPRselect = toggleEPRselect

clearSelectedEPRs = () ->
    window.selected_eprs = []
    window.selected_epr_orders = []
    $("tr.selected-epr").removeClass "selected-epr"
    validateEPRselection()
window.clearSelectedEPRs = clearSelectedEPRs

getEntitysProperties = (relationship_ids) ->
    params = $.param( { 
        selected_egrs: relationship_ids
        selected_properties: window.selected_properties, 
        selected_groups: window.selected_groups, 
        property_search: $("input#property_search_field").val(), 
        property_direction: window.property_direction, 
        property_sort: window.property_sort 
        } )
    $
    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/eprs?" + params
        type: 'POST'
window.getEntitysProperties = getEntitysProperties

topEPRs = (relationship_ids) ->
    params = $.param( { 
            selected_eprs: relationship_ids, 
            selected_egrs: window.selected_egrs 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/top_eprs?" + params
        type: 'POST'
window.topEPRs = topEPRs

bottomEPRs = (relationship_ids) ->
    params = $.param( { 
            selected_eprs: relationship_ids, 
            selected_egrs: window.selected_egrs 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/bottom_eprs?" + params
        type: 'POST'
window.bottomEPRs = bottomEPRs

upEPRs = (relationship_ids) ->
    params = $.param( { 
            selected_eprs: relationship_ids, 
            selected_egrs: window.selected_egrs 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/up_eprs?" + params
        type: 'POST'
window.upEPRs = upEPRs

downEPRs = (relationship_ids) ->
    params = $.param( { 
            selected_eprs: relationship_ids, 
            selected_egrs: window.selected_egrs 
        } )

    #send the request to add the selected groups to the selected entity
    $.ajax 
        url: "/hub/down_eprs?" + params
        type: 'POST'
window.downEPRs = downEPRs

validateClearButton = () ->
    open = $("td.edit-epr-trigger.openForm")
    if window.selected_eprs.length > 0 && window.selected_egrs.length == 1 || open.length > 0
        $("#clear-selected-eprs").removeClass("disabled")
    else
        $("#clear-selected-eprs").addClass("disabled")

validateEPRselection = () ->
    validateClearButton()
    
    orders = window.selected_epr_orders

    if orders.length < 1 || window.selected_egrs.length > 1
        $("div.property-order-action").removeClass "enabled"
        $("div.property-order-action").addClass "disabled"
    else
        valid = orders.length * ( orders.length + 1) / 2
        sum = 0
        try 
            sum += eval(order) for order in orders
        catch e
            console.log e
        finally
            $("div#up-selected-eprs").removeClass "enabled"
            $("div#up-selected-eprs").addClass "disabled"
            $("div#top-selected-eprs").removeClass "enabled"
            $("div#top-selected-eprs").addClass "disabled"
        # index_first = $.inArray "1", orders
        # if index_first > -1 && orders.length == 1
        if sum <= valid
            $("div#up-selected-eprs").removeClass "enabled"
            $("div#up-selected-eprs").addClass "disabled"
            $("div#top-selected-eprs").removeClass "enabled"
            $("div#top-selected-eprs").addClass "disabled"
        else
            $("div#up-selected-eprs").removeClass "disabled"
            $("div#up-selected-eprs").addClass "enabled"
            $("div#top-selected-eprs").removeClass "disabled"
            $("div#top-selected-eprs").addClass "enabled"
        # index_last = $.inArray maxOrder, orders
        valid = false
        index = $.inArray window.selected_epr_max_order + "", orders
        if index < 0
            valid = true
        else
        # if orders.length == 1
        #     if index < 0
        #         valid = true
        # else
            try
                orders.sort()
                # for(i = 0; i < orders.length - 1; i++)
                #     test = eval(orders[i]) + eval(orders[i+1])
                #     if test > 1
                #         valid = true
                #         break
                i = 0
                while i < orders.length - 1
                  test = eval(orders[i+1]) - eval(orders[i])
                  if test > 1
                    valid = true
                    break
                  i++
            catch e
                console.log e
            finally
                $("div#down-selected-eprs").removeClass "enabled"
                $("div#down-selected-eprs").addClass "disabled"
                $("div#bottom-selected-eprs").removeClass "enabled"
                $("div#bottom-selected-eprs").addClass "disabled"
        unless valid
            $("div#down-selected-eprs").removeClass "enabled"
            $("div#down-selected-eprs").addClass "disabled"
            $("div#bottom-selected-eprs").removeClass "enabled"
            $("div#bottom-selected-eprs").addClass "disabled"
        else
            $("div#down-selected-eprs").removeClass "disabled"
            $("div#down-selected-eprs").addClass "enabled"
            $("div#bottom-selected-eprs").removeClass "disabled"
            $("div#bottom-selected-eprs").addClass "enabled"


window.validateEPRselection = validateEPRselection
