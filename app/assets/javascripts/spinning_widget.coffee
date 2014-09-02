#= require spin.min

class Dashing.WidgetWithSpinner extends Dashing.Widget

  loadView: (_node) ->
    super(_node)

    if $(_node).hasClass('editable')
      button = $('<a class="btn btn-default btn-editar-painel" data-toggle="modal" data-target="#editar-painel">Editar</a>')
      button.appendTo($(_node))

    return _node

  show_spinner: (color) ->
    
    @spinner_node = $('<div class="spinner"></div>')
    
    @spinner_node.appendTo($(@node).parent('.gs_w'))
    
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

    @spinner = new Spinner(opts)

    @spinner.spin(@spinner_node.get()[0])

  hide_spinner: ->
    $(@spinner_node).hide()
