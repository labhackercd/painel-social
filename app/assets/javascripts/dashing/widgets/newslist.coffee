#= require spinning_widget

class Dashing.Newslist extends Dashing.WidgetWithSpinner
  showOrHideSpinner: ->
    if not @get('items')
      @show_spinner('#fff')
    else
      @hide_spinner()

  @::on 'viewDidAppear', ->
    @showOrHideSpinner()

  @::on 'data', ->
    @showOrHideSpinner()

    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()
