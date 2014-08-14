#= require spinning_widget

class Dashing.Comments extends Dashing.WidgetWithSpinner

  @accessor 'quote', ->
    "“#{@get('current_comment')?.body}”"

  @::on 'ready', ->
    @currentIndex = 0
    @commentElem = $(@node).find('.comment-container')
    @nextComment()

  onData: (data) ->
    @currentIndex = 0
    @nextComment()

  startCarousel: ->
    setInterval(@nextComment, 8000)

  nextComment: =>
    comments = @get('comments')

    if comments
      @hide_spinner()
      @startCarousel()

      @commentElem.fadeOut =>
        @currentIndex = (@currentIndex + 1) % comments.length
        @set 'current_comment', comments[@currentIndex]
        @commentElem.fadeIn()
    else
      @show_spinner('#fff')
