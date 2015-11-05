import d3 from 'd3';
var React = require('react');
var ReactDOM = require('react-dom');
var Bubbles = require('./components/bubbles.jsx');

d3.json('data/projetosdelei.json', function(err, data) {
  ReactDOM.render(
    <Bubbles width={1024} height={500} data={data} />,
    document.getElementById('main')
  );
});
