#= require spin.min


class Dashing.WidgetWithSpinner extends Dashing.Widget

  closestWidget: ->
    # XXX FIXME li may not be the best selector here
    return $(@node).closest('li')

  show_spinner: (color) ->

    if @spinner
      return

    if not color
      color = '#666666'

    opts =
      lines: 13 # The number of lines to draw
      length: 0 # The length of each line
      width: 10 # The line thickness
      radius: 30 # The radius of the inner circle
      corners: 1 # Corner roundness (0..1)
      rotate: 0 # The rotation offset
      direction: 1 # 1: clockwise, -1: counterclockwise
      color: color # #rgb or #rrggbb or array of colors
      speed: 1 # Rounds per second
      trail: 60 # Afterglow percentage
      shadow: false # Whether to render a shadow
      hwaccel: false # Whether to use hardware acceleration
      className: 'spinner' # The CSS class to assign to the spinner
      zIndex: 2e9 # The z-index (defaults to 2000000000)
      top: '50%' # Top position relative to parent
      left: '50%' # Left position relative to parent

    @spinner = (new Spinner(opts)).spin()
    @closestWidget().append(@spinner.el)

  hide_spinner: ->
    if @spinner
      @closestWidget().find(@spinner.el).remove()
      @spinner = null
