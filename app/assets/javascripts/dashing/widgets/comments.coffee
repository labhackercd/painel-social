#= require spinning_widget

class Dashing.Comments extends Dashing.WidgetWithSpinner

  @accessor 'quote', ->
    "“#{@get('current_comment')?.body}”"

  @::on 'ready', ->
    @nextComment()

  onData: (data) ->
    @nextComment()

  startCarousel: ->
    setInterval(@nextComment, 8000)

  nextComment: () =>
    comments = @get('comments')

    if !comments
      @show_spinner()
    else
      @hide_spinner()

      @commentElem = $(@node).find('.comment-container')
      @commentElem?.fadeOut =>
        if !@is_carousel_started
          @is_carousel_started = true
          @startCarousel()
        @currentIndex = 0 unless @currentIndex?
        @currentIndex = (@currentIndex + 1) % comments.length
        @set 'current_comment', comments[@currentIndex]
        @commentElem.fadeIn()
