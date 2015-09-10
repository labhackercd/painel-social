var React = require('react');

var gsap = require('gsap');
var gsap_plugin_react = require('gsap-react-plugin');

var Time = require('react-time');

function isNumber(obj) {
  return toString.call(value) === '[object Number]';
}

var TimeSince = React.createClass({
  displayName: 'TimeSince',

  getDefaultProps: function() {
    return {
      updateInterval: 5000
    };
  },

  componentDidMount: function() {
    this.resetTicker();
  },

  componentWillUnmount: function() {
    this.clearTicker();
  },

  componentWillReceiveProps: function(nextProps) {
    if (typeof nextProps.updateInterval !== 'undefined') {
      this.resetTicker();
    }
  },

  clearTicker: function() {
    if (this.ticker) {
      return clearInterval(this.ticker);
    }
  },

  resetTicker: function() {
    this.clearTicker();
    return this.ticker = setInterval(this.invalidate, this.props.updateInterval);
  },

  invalidate: function() {
    this.forceUpdate();
  },

  render: function() {
    return <Time {...this.props} relative={true} />
  }
});

var TweetDisplay = React.createClass({
  render: function() {
    // TODO FIXME *dangerouslySetInnerHTML* is probably dangerous, isn't it?

    var quotedText = '"' + this.props.text + '"';

    return (
      <div className="TweetDisplay">
        <h3>
          <img src={this.props.authorImage} />
          <span className="author">{this.props.author}</span>
        </h3>

        <p className="comment" dangerouslySetInnerHTML={{__html: quotedText}} />
        <TimeSince value={this.props.publishedAt} updateInterval={1000} />
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

  componentWillReceiveProps: function(nextProps) {
    var receivedTweets = typeof nextProps.tweets !== 'undefined';
    var receivedInterval = typeof nextProps.interval !== 'undefined';

    if (receivedTweets) {
      this.setState({currentIndex: 0});
    }

    if (receivedTweets || receivedInterval) {
      this.resetTicker();
    }
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

    // Duration of the whole "fade-out, fade-in" animation, in seconds.
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
    var tweets = this.props.tweets;
    var current = tweets.length === 0 ? null : tweets[this.state.currentIndex];

    if (current) {
      current = <TweetDisplay {...current} />;
    }

    var style = {opacity: this.state.opacity};

    return (
      <div className="TweetCarousel">
        <h1 className="title">{this.props.title}</h1>
        <div style={style}>{current}</div>
      </div>
    );
  }
});

module.exports = TweetCarousel;
