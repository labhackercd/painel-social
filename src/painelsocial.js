var d3 = require('d3');
var React = require('react');
var Bubbles = require('./components/bubbles.jsx');
var TweetCarousel = require('./components/tweetcarousel.jsx');
var WordCloud = require('./components/wordcloud.jsx');
var NewsList = require('./components/newslist.jsx');

var PainelSocial = React.createClass({
  render: function() {
    return  React.createElement(
      'div', {className: 'PainelSocial'},
      React.createElement(Bubbles, {width: 500, height: 400, data: this.props.causabrasil}),
      React.createElement(TweetCarousel, {tweets: this.props.mentions.comments}),
      React.createElement(WordCloud, React.__spread({width: 500, height: 400}, this.props.wordcloud)),
      React.createElement(NewsList, React.__spread({title: 'Mais Lidas da Agência Câmara'}, this.props.noticiasagenciacamara))
    );
  }
});

d3.json('data/painelsocial.json', function(err, data) {
  React.render(
    React.createElement(PainelSocial, React.__spread({}, data)),
    document.getElementById('main')
  );
});
