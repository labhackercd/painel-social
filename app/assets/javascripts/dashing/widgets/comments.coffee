#= require spinning_widget

class Dashing.Comments extends Dashing.WidgetWithSpinner

  @accessor 'quote', ->
    "“#{@get('currentComment')?.body}”"

  @::on 'ready', ->
    @show_spinner()

  onData: ->
    @hide_spinner()

    if @get('comments')
      @currentIndex = 0
      @cycleComments()
      clearInterval(@carousel) if @carousel
      @carousel = setInterval(@cycleComments.bind(@), 8000)

  cycleComments: ->
    comments = @get('comments')

    @commentElem = $(@node).find('.comment-container')
    @commentElem?.fadeOut =>
      @set 'currentComment', comments[@currentIndex]
      @currentIndex = (@currentIndex + 1) % comments.length
      @commentElem.fadeIn()
