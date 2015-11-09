import React from 'react';
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
  constructor(props) {
    super(props);
    this.state = {
      currentIndex: 0
    };
  }

  componentWillMount() {
    this.setState({currentIndex: 0});
  }

  componentDidMount() {
    this.resetTicker();
  }

  componentWillUnmount() {
    this.clearTicker();
  }

  componentWillReceiveProps(nextProps) {
    this.setState({currentIndex: 0});
    this.resetTicker();
  }

  resetTicker() {
    this.clearTicker();
    this.ticker = setInterval(() => this.rotate(), this.props.interval);
  }

  clearTicker() {
    if (this.ticker) {
      clearInterval(this.ticker);
    }
  }

  rotate() {
    // TODO animation, like fade-in:fade-out
    let nextIndex = this.state.currentIndex + 1;

    if (nextIndex >= this.props.tweets.length) {
      nextIndex = 0;
    }

    this.setState({currentIndex: nextIndex});
  }

  render() {
    let {tweets, title} = this.props;
    let {currentIndex} = this.state;

    let current = tweets.length === 0 ? null : tweets[currentIndex];

    if (current) {
      current = <TweetDisplay {...current} />;
    }

    return (
      <div className="TweetCarousel">
        <h1 className="title">{title}</h1>
        <div>{current}</div>
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
