# data-target -> data-batmantarget
Batman.DOM.readers.batmantarget = Batman.DOM.readers.target
Batman.DOM.readers.target = null
delete Batman.DOM.readers.target

# Customary dashing initialization
Dashing.widget_margins ||= [5, 5]
Dashing.numColumns ||= 5
Dashing.debugMode = true


widget_width = ($(window).width() - (Dashing.widget_margins.reduce (t, s) -> t + s) * (Dashing.numColumns + 1) ) / Dashing.numColumns
widget_height = ($(window).height() / 2) - (Dashing.widget_margins.reduce (t, s) -> t + s) * 1.5

Dashing.widget_base_dimensions ||= [widget_width, widget_height]


Dashing.on 'ready', ->
  
  contentWidth = (Dashing.widget_base_dimensions[0] + Dashing.widget_margins[0] * 2) * Dashing.numColumns

  Batman.setImmediate ->
    $('.gridster').width(contentWidth)
    $('.gridster ul:first').gridster
      widget_margins: Dashing.widget_margins
      widget_base_dimensions: Dashing.widget_base_dimensions
      avoid_overlapped_widgets: !Dashing.customGridsterLayout
      draggable:
        stop: Dashing.showGridsterInstructions
