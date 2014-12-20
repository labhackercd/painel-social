var d3 = require('d3');
var React = require('react');
var Bubbles = require('./components/bubbles.jsx');
var TweetCarousel = require('./components/tweetcarousel.jsx');
var WordCloud = require('./components/wordcloud.jsx');
var NewsList = require('./components/newslist.jsx');

var PainelSocial = React.createClass({
  render: function() {
    return (
      <div className="PainelSocial">
        <Bubbles width={500} height={400} data={this.props.causabrasil} />
        <TweetCarousel tweets={this.props.mentions.comments} />
        <WordCloud width={500} height={400} {...this.props.wordcloud} />
        <NewsList title={'Mais Lidas da Agência Câmara'} {...this.props.noticiasagenciacamara} />
      </div>
    );
  }
});

d3.json('data/painelsocial.json', function(err, data) {
  React.render(
    <PainelSocial {...data} />,
    document.getElementById('main')
  );
});
