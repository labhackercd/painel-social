var Comments = React.createClass({
  render: function() {
    return (
      <h1 className="title">{this.state.title}</h1>
      <div className="comment-container">
        <h3>
          <img data-bind-src='currentComment.avatar' />
          <span className="author">{this.state.author}</span>
        </h3>
        <p className="comment">{this.state.comment}</p>
      </div>

      <p className="more-info">{this.state.timeago}</p>
    );
  }
});

class Dashing.Comments extends Dashing.WidgetWithSpinner

  @accessor 'quote', ->
    "“#{@get('currentComment')?.body}”"

  @accessor 'timeago', ->
    cur = @get('currentComment')?.created_at
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
