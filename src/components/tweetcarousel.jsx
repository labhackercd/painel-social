/**
 * TODO Display *time since*
 * TODO Remove dangerouslySetInnerHTML usage.
 */

var React = require('react');

var gsap = require('gsap');
var gsap_plugin_react = require('gsap-react-plugin');

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
    return {currentIndex: 0, opacity: 1};
  },

  componentDidMount: function() {
    this.resetTicker();
  },

  componentWillUnmount: function() {
    this.clearTicker();
  },

  componentWillReceiveProps: function() {
    this.setState({currentIndex: 0});
    this.resetTicker();
  },

  clearTicker: function() {
    if (this.ticker) {
      clearInterval(this.ticker);
    }
  },

  resetTicker: function() {
    this.clearTicker();
    this.ticker = setInterval(this.rotate, this.props.interval);
  },

  rotate: function() {
    var nextIndex = this.state.currentIndex + 1;
    if (nextIndex >= this.props.tweets.length) {
      nextIndex = 0;
    }

    var fadeDuration = 1;

    TweenLite.to(this, fadeDuration / 2, {
      state: {opacity: 0},
      onComplete: (function() {
        this.setState({currentIndex: nextIndex});
        TweenLite.to(this, fadeDuration / 2, {state: {opacity: 1}});
      }).bind(this)
    });
  },

  render: function() {
    // FIXME If there is no current, there should be no TweetDisplay,
    // but I don't know how to make it's rendering optional. I'm sorry.
    var current = this.props.tweets.length ? this.props.tweets[this.state.currentIndex] : null;

    function conditionallyRenderTweetDisplay() {
      if (current) {
        return (<TweetDisplay {...current} />);
      } else {
        return null;
      }
    }

    var style = {opacity: this.state.opacity};

    return (
      <div className="TweetCarousel">
        <h1 className="title">{this.props.title}</h1>
        <div style={style}>
          {conditionallyRenderTweetDisplay()}
        </div>
      </div>
    );
  }
});

module.exports = TweetCarousel;
