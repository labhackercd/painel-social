var d3 = require('d3');
var React = require('react');
var Bubbles = require('./components/bubbles.jsx');

d3.json('data/projetosdelei.json', function(err, data) {
  React.render(
    <Bubbles width={1024} height={500} data={data} />,
    document.getElementById('main')
  );
});
