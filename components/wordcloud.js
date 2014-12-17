// TODO depends on d3.layout.cloud.js. We should require that once using
//      browserify.

var WordCloud = {};

WordCloud.create = function(el, props, state) {
  // Create the visualization
  var svg = d3.select(el)
    .append('svg')
    .attr('class', 'wordcloud')
    .attr('width', props.width)
    .attr('height', props.height);

  this.update(el, props, state);
};

WordCloud.update = function(el, props, state) {
  var words = state.value;
  return this._doTheThing(el, props, words);
};

WordCloud.destroy = function(el) {
  // Any cleanup goes here
};

WordCloud._doTheThing = function(el, props, words) {
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

WordCloud._drawFn = function(el, width, height, fill) {
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

var d3WordCloud = WordCloud;

WordCloud = React.createClass({
  componentDidMount: function() {
    var el = this.getChartDOMNode();
    d3WordCloud.create(el, this.props, this.getChartState());
  },

  componentDidUpdate: function() {
    var el = this.getChartDOMNode();
    d3WordCloud.update(el, this.props, this.getChartState());
  },

  componentWillUnmount: function() {
    var el = this.getChartDOMNode();
    d3WordCloud.destroy(el);
  },

  getChartState: function() {
    return this.props.data;
  },

  getChartDOMNode: function() {
    return this.getDOMNode().getElementsByClassName('WordCloudChart')[0];
  },

  render: function() {
    return (
      <div className="WordCloud">
        <h1 className="title">{this.props.title}</h1>
        <div className="WordCloudChart"></div>
        <p className="more-info">{this.props.moreinfo}</p>
      </div>
    );
  }
});

