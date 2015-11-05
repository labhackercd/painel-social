import d3 from 'd3';
import React from 'react';
import ReactDOM from 'react-dom';
import Bubbles from './components/bubbles.jsx';
import NewsList  from './components/newslist.jsx';
import TweetCarousel from './components/tweetcarousel.jsx';
import WordCloud from './components/wordcloud.jsx';

const PainelSocial = ({causabrasil, mentions, wordcloud, noticiasagenciacamara}) => (
    <div className="PainelSocial">
        <Bubbles width={500} height={400} data={causabrasil} />
        <TweetCarousel tweets={mentions.comments} />
        <WordCloud width={500} height={400} {...wordcloud} />
        <NewsList title={'Mais Lidas da Agência Câmara'} {...noticiasagenciacamara} />
    </div>
);

d3.json('data/painelsocial.json', function(err, data) {
  ReactDOM.render(
      <PainelSocial {...data} />,
      document.getElementById('main')
  );
});
