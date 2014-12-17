/**
 * TODO Display *time since*
 * TODO Fade-in and fade-out effects while cycling
 * TODO Remove dangerouslySetInnerHTML usage.
 * TODO Find a way to not render TweetDisplay inside TweetCarousel when there
 *      isn't a *current* tweet to display. This is a pretty edge case, but
 *      we should deal with it anyway.
 */

var TweetDisplay = React.createClass({
  render: function() {
    // TODO FIXME We shouldn't be using *dangerouslySetInnerHTML* here!
    // It's dangerous!

    var quotedText = '"' + this.props.text + '"';

    return (
      <div className="TweetDisplay">
        <h3>
          <img src={this.props.authorImage} />
          <span className="author">{this.props.author}</span>
        </h3>

        <p className="comment" dangerouslySetInnerHTML={{__html: quotedText}} />
      </div>
    );
  }
});

var TweetCarousel = React.createClass({
  getDefaultProps: function() {
    return {title: 'Twitter', interval: 8000, tweets: []};
  },

  getInitialState: function() {
    return {currentIndex: 0};
  },

  componentDidMount: function() {
    this.resetTicker();
  },

  componentWillUnmount: function() {
    if (this.ticker) {
      clearInterval(this.ticker);
    }
  },

  resetTicker: function() {
    if (this.ticker) {
      clearInterval(this.ticker);
    }
    this.ticker = setInterval(this.rotate, this.props.interval);
  },

  componentWillReceiveProps: function() {
    this.setState({currentIndex: 0});
    this.resetTicker();
  },

  rotate: function() {
    var nextIndex = this.state.currentIndex + 1;
    if (nextIndex >= this.props.tweets.length) {
      nextIndex = 0;
    }
    this.setState({currentIndex: nextIndex});
  },

  render: function() {
    // FIXME If there is no current, there should be no TweetDisplay,
    // but I don't know how to make it's rendering optional. I'm sorry.
    var current = this.props.tweets.length ? this.props.tweets[this.state.currentIndex] : null;
    return (
      <div className="TweetCarousel">
        <h1 className="title">{this.props.title}</h1>
        <TweetDisplay {...current} />
      </div>
    );
  }
});
