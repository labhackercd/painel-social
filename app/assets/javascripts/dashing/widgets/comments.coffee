#= require spinning_widget
#= require moment
#= require moment/locale/pt-br

class Dashing.Comments extends Dashing.WidgetWithSpinner

  @accessor 'quote', ->
    "“#{@get('currentComment')?.text}”"

  @accessor 'timeago', ->
    cur = @get('currentComment')?.published_at
    moment.locale('pt-br')
    moment(cur).fromNow() if cur

  showOrHideSpinner: ->
    if not @get('comments')
      @show_spinner('#fff')
    else
      @hide_spinner()

  @::on 'viewDidAppear', ->
    @showOrHideSpinner()

  @::on 'data', ->
    @showOrHideSpinner()

    comments = @get('comments')

    if not comments
      clearInterval(@carousel) if @carousel
      @set 'currentComment', null
      $(@node).find('.comment-container').hide()
    else
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
