import React from 'react';
import gsap from 'gsap';
import gsap_react_plugin from 'gsap-react-plugin';
import Time from 'react-time';

class TimeSince extends React.Component {
  componentDidMount() {
    this.resetTicker();
  }

  componentWillUnmount() {
    this.clearTicker();
  }

  componentWillReceiveProps(nextProps) {
    if (typeof nextProps.updateInterval !== 'undefined') {
      this.resetTicker();
    }
  }

  clearTicker() {
    if (this.ticker) {
      return clearInterval(this.ticker);
    }
  }

  resetTicker() {
    this.clearTicker();
    return this.ticker = setInterval(this.invalidate, this.props.updateInterval);
  }

  invalidate() {
    // FIXME This is probably not working!
    if (this.forceUpdate) {
      this.forceUpdate();
    }
  }

  render() {
    return <Time {...this.props} relative={true} />;
  }
}

TimeSince.displayName = 'TimeSince';

TimeSince.defaultProps = {
  updateInterval: 5000
};

const TweetDisplay = (props) => (
    // TODO FIXME *dangerouslySetInnerHTML* is probably dangerous, isn't it?
    <div className="TweetDisplay">
      <h3>
        <img src={props.authorImage} />
        <span className="author">{props.author}</span>
      </h3>

      <p className="comment" dangerouslySetInnerHTML={{__html: '"' + props.text + '"'}} />
      <TimeSince value={props.publishedAt} updateInterval={1000} />
    </div>
);

class TweetCarousel extends React.Component {
  constructor() {
    super();
    this.state = {currentIndex: 0, opacity: 1};
  }

  componentDidMount() {
    this.resetTicker();
  }

  componentWillUnmount() {
    this.clearTicker();
  }

  componentWillReceiveProps(nextProps) {
    var receivedTweets = typeof nextProps.tweets !== 'undefined';
    var receivedInterval = typeof nextProps.interval !== 'undefined';

    if (receivedTweets) {
      this.setState({currentIndex: 0});
    }

    if (receivedTweets || receivedInterval) {
      this.resetTicker();
    }
  }

  clearTicker() {
    if (this.ticker) {
      clearInterval(this.ticker);
    }
  }

  resetTicker() {
    this.clearTicker();
    this.ticker = setInterval(this.rotate, this.props.interval);
  }

  rotate() {
    let nextIndex = this.state.currentIndex + 1;

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
  }

  render() {
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
}

TweetCarousel.defaultProps = {
  title: 'Twitter',
  interval: 8000,
  tweets: []
};

export default TweetCarousel;
