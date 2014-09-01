#= require jquery.gridster.js
#= require dashing.gridster


Dashing.widget_margins ||= [5, 5]
Dashing.widget_base_dimensions ||= [300, 360]
Dashing.numColumns ||= 5
#Dashing.debugMode = true


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
