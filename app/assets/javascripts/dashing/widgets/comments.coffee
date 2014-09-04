#= require spinning_widget

class Dashing.Comments extends Dashing.WidgetWithSpinner

  @accessor 'quote', ->
    "“#{@get('currentComment')?.body}”"

  @::on 'data', ->
    comments = @get('comments')

    if not comments
      @show_spinner()
      clearInterval(@carousel) if @carousel
      @set 'currentComment', null
      $(@node).find('.comment-container').hide()
    else
      @hide_spinner()
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
