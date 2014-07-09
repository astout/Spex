toggleChevron = (e) ->
    $(e.target)
        .prev '.panel-heading'
        .find 'i.collapse-indicator'
        .toggleClass 'glyphicon-chevron-down glyphicon-chevron-right'
window.toggleChevron = toggleChevron