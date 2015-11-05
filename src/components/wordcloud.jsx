import d3 from 'd3';
import React from 'react';
import ReactDOM from 'react-dom';

// TODO Shouldn't we try to rename this mess?
if (!d3.layout) d3.layout = {};
if (!d3.layout.cloud) d3.layout.cloud = require('../vendor/d3.layout.cloud');

var WordCloudHelper = {};

WordCloudHelper.create = function(el, props) {
  // Create the visualization
  var svg = d3.select(el)
    .append('svg')
    .attr('class', 'wordcloud')
    .attr('width', props.width)
    .attr('height', props.height);

  this.update(el, props);
};

WordCloudHelper.update = function(el, props) {
  var words = props.value;
  return this._doTheThing(el, props, words);
};

WordCloudHelper.destroy = function(el) {
  // Any cleanup goes here
};

WordCloudHelper._doTheThing = function(el, props, words) {
  var fill = d3.scale.linear()
    .domain([0, 1, 2])
    .range(["#222", "#333", "#444"]);

  // Remove any previously rendered wordcloud
  // TODO test that this works and nothing leaks
  d3.select(el).select('svg').selectAll('g').remove();

  return d3.layout.cloud()
    .size([props.width, props.height])
    .words(words)
    .padding(5)
    //.rotate(() -> ~~(Math.random() * 2) * 30; )
    .rotate(function() { return ~~(Math.random() * 2) * 90 })
    .rotate(0)
    //.font("Impact")
    .fontSize(function(d) { return d.size })
    .on("end", this._drawFn(el, props.width, props.height, fill))
    .start();
};

WordCloudHelper._drawFn = function(el, width, height, fill) {
  return function(words) {
    d3.select(el).select('svg')
      .append('g')
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")
      .selectAll("text")
      .data(words)
      .enter()
      .append("a")
      .attr("xlink:href", function(d) { return d.link })
      .attr("xlink:target", "_blank")
      .append("text")
      .style("font-size", function(d) { return d.size + "px"})
      .style("font-weight", "600")
      //.style("font-family", "Impact")
      .style("fill", function(d, i) { return fill(i) })
      .attr("text-anchor", "middle")
      .attr("transform", function(d) { return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")" })
      .text(function(d) { return d.text });
  };
};

export default class WordCloud extends React.Component {
  componentDidMount() {
    var el = this.getChartDOMNode();
    WordCloudHelper.create(el, this.props);
  }

  componentDidUpdate() {
    var el = this.getChartDOMNode();
    WordCloudHelper.update(el, this.props);
  }

  componentWillUnmount() {
    var el = this.getChartDOMNode();
    WordCloudHelper.destroy(el);
  }

  getChartDOMNode() {
    return ReactDOM.findDOMNode(this).getElementsByClassName('WordCloudHelperChart')[0];
  }

  render() {
    return (
      <div className="WordCloudHelper">
        <h1 className="title">{this.props.title}</h1>
        <div className="WordCloudHelperChart"></div>
        <p className="more-info">{this.props.moreinfo}</p>
      </div>
    );
  }
};
