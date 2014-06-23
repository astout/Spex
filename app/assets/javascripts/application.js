// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require turbolinks
//= require_tree .

$(function()
{
    $("[data-toggle='tooltip']").tooltip();
});

function collapisbles () {
    $(".nav-sidenav > li").on("show.bs.collapse", function () {
        $(this).addClass("sidenav-active-background");
    });
    $(".panel").on("hidden.bs.collapse", function (e) {
        e.stopPropagation();
        $('.glyphicon-chevron-down').addClass("glyphicon-chevron-right");
        $('.glyphicon-chevron-down').removeClass("glyphicon-chevron-down");
        alert("hidden");
    });

}

function toggleCollapseGlyph (tag) {
    if($(tag).hasClass("glyphicon-chevron-right"))
    {
        $(tag).removeClass("glyphicon-chevron-right");
        $(tag).addClass("glyphicon-chevron-down");
    }
    else if ($(tag).hasClass("glyphicon-chevron-down")) 
    {
        $(tag).removeClass("glyphicon-chevron-down");
        $(tag).addClass("glyphicon-chevron-right");
    }
}

$('.link_to_add_property_association').bind('ajax:beforeSend', function() {

});

$('.link_to_add_property_association').bind('ajax:complete', function() {
    
});

function add_parent (parent_id) {
    $('#add_property_'+parent_id).hide();
    var html = "<li id="+parent_id+">"+parent_id+"</li> ";
    $('#parents').append(html);
}

var printObj = function(obj) {
    var arr = [];
    $.each(obj, function(key, val) {
        var next = key + ": ";
        next += $.isPlainObject(val) ? printObj(val) : val;
        arr.push( next );
    });
    return "{ " +  arr.join(", ") + " }";
};


window.getParameterByName = function( name,href )
{
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( href );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}
