# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.save_def_change = 0
window.test = 0


$ ->

    if $('body').hasClass "roles"
        console.log("roles");
        $("input[type='text']").prop("autocomplete", "off")
        $("#delete-confirm").on "shown.bs.modal", (e) ->
            console.log("show delete confirm")
            $("span#new-default").html($("select#new-default")[0].options[$("select#new-default")[0].selectedIndex].text)
        $("#default-confirm").on "hidden.bs.modal", (e) ->
            _def_change = $("button.def-change.selected")[0].id
            console.log("change defaults: " + _def_change)
            if window.save_def_change > 0
                $("input#role_change_defaults").val(_def_change)
            else
                $("button#role_default").click()
            window.save_def_change = 0

        setLabel("role_admin")
        setLabel("role_default")
        setLabel("role_change_view")

        unless $('body').hasClass "roles-index"
            validateName($("input#role_name").val())

        $("body").on "click", "button.role-bool", (e) ->
            e.preventDefault()
            _id = this.id
            console.log("id: " + _id)
            $("input#"+_id).val(!($("input#"+_id).val() == "true")) 
            console.log($("input#"+_id).val())
            setLabel(_id)
            if _id == "role_default"
                if $("input#"+_id).val() == "false"
                    resetDefaultChangeButtons()
                console.log("default button clicked")
                confirmDefault()
            return false

        $("body").on "input", "input#role_name", (e) ->
            validateName $(this).val() 

        $("body").on "keydown", "input#role_name", (e) ->
            if e.keyCode == 13
                e.preventDefault()
                return false

        $("body").on "click", "button.def-change", (e) ->
            e.preventDefault()
            _true = $("button#true")
            _false = $("button#false")
            clicked = this.id
            if clicked == _true[0].id && !_true.hasClass("selected")
                _false.removeClass("selected")
                _false.removeClass("btn-success")
                _true.addClass("selected")
                _true.addClass("btn-danger")
                $("span#final-message").html("WILL BE")
                $("span#final-message").removeClass("alert-success")
                $("span#final-message").addClass("alert-danger")
                $("input#role_change_default_users").val("true")
            else if clicked == _false[0].id && !_false.hasClass("selected")
                _true.removeClass("selected")
                _true.removeClass("btn-danger")
                _false.addClass("selected")
                _false.addClass("btn-success")
                $("span#final-message").html("WILL NOT BE")
                $("span#final-message").removeClass("alert-danger")
                $("span#final-message").addClass("alert-success")
                $("input#role_change_default_users").val("false")
            return false


        $("body").on "click", "span.delete", (e) ->
            deleteModal(this.id)
            console.log "delete role clicked"

        $("body").on "click", "span.default", (e) ->
            console.log "delete default clicked"

        $("body").on "click", "button.close-modal", (e) ->
            if $(this).hasClass("save")
                save_def_change++
                test++
            # else
            #     window.save_def_change = false
            #     $("input#role_default").val("false")
            #     setLabel("role_default")
            #     resetDefaultChangeButtons()
            return

        $("body").on "change", "select#new-role", (e) ->
            new_role = this.options[this.selectedIndex].innerHTML
            if new_role.length > 0
                new_role = new_role[0].toUpperCase() + new_role.slice(1)
            $("span#new-role").html(new_role)

        $("body").on "click", "button#btn-delete-confirm", (e) ->
            console.log "confirm delete"
            params = $.param( {
                id: $("span.delete-role-id")[0].id
                new_id: $("select#new-default").val()
                })
            $.ajax
                url: "/roles/confirm_delete?" + params
                type: 'POST'

        #Every character change in Search field, submit query
        $("body").on "input", "input#role_search", (e) ->
            console.log $(this).val()
            params = get_role_params()
            #send the request
            $.get "roles?" + params
            false

get_role_params = () ->
    params = $.param( {
        role_search: $("input#role_search").val(), 
        roles_page: "1",
        event: "role"
    })
    return params

deleteModal = (_id) ->
    if _id.length < 1
        return false
    params = $.param( { 
      id: _id,
      } )
    $.ajax 
      url: "/roles/delete_request?" + params
      type: 'POST'    

resetDefaultChangeButtons = () ->
    $("div#def-change").html('
    <button type="button" id="false" class="btn btn-default btn-success btn-sm selected def-change">Don\'t Change</button>
    <button type="button" id="true" class="btn btn-default btn-sm def-change">Change</button>
    ')
    $("input#role_change_defaults").val("false")
    $("span#final-message").html("WILL NOT BE")
    $("span#final-message").removeClass("alert-danger")
    $("span#final-message").addClass("alert-success")

setLabel = (id) ->
    if $("input#"+id).val() == "true"
        $("button#"+id).removeClass("btn-default")
        $("button#"+id).addClass("btn-success")
    else
        $("button#"+id).removeClass("btn-success")
        $("button#"+id).addClass("btn-default")

confirmDefault = () ->
    default_val = $("input#role_default").val()
    console.log "val: " + default_val
    if default_val == "true"
        $("#default-confirm").modal("show")

validateName = (input) ->
    label = $("span#role_name")
    submit = $("input[type=submit]")
    rx = /^[A-Za-z0-9]+[A-Za-z0-9\-\_]*[A-Za-z0-9]+$/
    if input.length > 0 && rx.test(input) && label.hasClass("label-default")
        label.removeClass("label-default")
        label.addClass("label-success")
        submit.removeClass("disabled")
        $("body").on "keydown", "input.role", (e) ->
          console.log "enter valid"
          if e.keyCode == 13
            $("form").submit()
    if (input.length < 1 || !rx.test(input)) && label.hasClass("label-success")
        label.removeClass("label-success")
        label.addClass("label-default")
        submit.addClass("disabled")
        $("body").on "keydown", "input.role", (e) ->
          console.log "enter valid"
          if e.keyCode == 13
            e.preventDefault()
            return false
    # if default_val == "true"


