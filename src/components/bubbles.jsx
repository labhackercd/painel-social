import _ from 'lodash';
import d3 from 'd3';
import React from 'react';
import ReactDOM from 'react-dom';

var BubblesHelper = {};

BubblesHelper.create = function(el, props, state) {
  // Create the visualization
  var svg = d3.select(el)
    .append('svg')
    .attr('class', 'd3')
    .attr('width', props.width)
    .attr('height', props.height);

  this.update(el, props, state);
};

BubblesHelper.update = function(el, props, state) {
  var nodes = this._createNodes(props, state);
  return this._drawAndAnimateBubblesHelper(el, props, state, nodes);
};

BubblesHelper.destroy = function(el) {
  // Any cleanup goes here
};

BubblesHelper._createNodes = function(props, state) {
  var fillColors = state.fillColors;
  var minRadius = state.minRadius;
  var maxRadius = state.maxRadius;
  var maxClusters = 10;
  var width = props.width;

  // use the max total_amount in the data as the max in the scale's domain
  var domainMax = d3.max(state.items, function(d) { return parseInt(d.value) });

  // Create the nodes
  var radiusScale = d3.scale.pow()
    .exponent(0.5)
    .domain([0, domainMax])
    .range([minRadius, maxRadius]);

  var nodes = _.map(state.items, (function(d) {
    return {
      id: d.label,
      label: d.label,
      label_lines: this._breakText(d.label),
      radius: radiusScale(parseInt(d.value)),
      value: d.value,
      category: d.categoria,
      tooltip: d.tooltip,
      fillColor: fillColors[d.categoria],
      x: Math.cos(d.categoria / maxClusters * 2 * Math.PI) * 400 + width / 2 + Math.random(),
      y: Math.cos(d.categoria / maxClusters * 2 * Math.PI) * 400 + self.height / 2 + Math.random()
    };
  }).bind(this));

  // Separate the nodes in clusters
  var clusters = new Array(maxClusters);

  _.each(nodes, function(d) {
    if (!clusters[d.category] || (d.r > clusters[d.category].radius)) {
      clusters[d.category] = d;
    }
  });

  // Assign each node their cluster
  _.each(nodes, function(d) {
    d.cluster = clusters[d.category];
  });

  // Return nodes, sorted
  return _.sortBy(nodes, function(d) { return d.value * (-1) });
};

BubblesHelper._drawAndAnimateBubblesHelper = function(el, props, state, nodes) {
  var width = props.width;
  var height = props.height;
  var padding = 1.5;
  var clusterPadding = 6;
  var layoutGravity = 0.08;
  var maxRadius = state.maxRadius;

  // Place the nodes in the graph as circles
  var circles = d3.select(el).select('svg')
    .selectAll('circle')
    .data(nodes, function(d) { return d.id });

  var node = circles.enter()
    .append('g')
    .attr('class', 'node');

  node.append('circle')
    .attr('r', 0)
    .attr("fill", function(d) { return d.fillColor })
    .attr("stroke-width", 2)
    .attr("stroke", function(d) { return d3.rgb(d.fillColor).darker() })
    .attr("id", function(d) { return 'bubble_' + d.id });

  node.append('text')
    .style("text-anchor", "middle")
    .attr("transform", function(d) { return "translate(0, " + (-10 * d.radius / 90) + ")" })
    .style("font-size", function(d) { return 18 * d.radius / 90 + "px" })
    .style("font-weight", "600")
    .attr("fill", "#000000")
    .text(function(d) { return d.label_lines[0] });

  node.append("text")
    .style("text-anchor", "middle")
    .attr("transform", function(d) { return "translate(0, " + 10 * d.radius / 90 + ")" })
    .style("font-size", function(d) { return 18 * d.radius / 90 + "px" })
    .style("font-weight", "600")
    .attr("fill", "#000000")
    .text(function(d) { return d.label_lines[1] });

  // Fancy transition that makes the bubbles appear by increasing their radius
  // until it reaches the right value
  circles.transition()
    .duration(2000)
    .delay(function(d, i) { return i * 5 })
    .select('circle')
    .attr('r', function(d) { return d.radius });

  // This is all that was in the old `start()` method. It started the force
  // and saved it in `this.force`.
  var force = d3.layout.force()
    .nodes(nodes)
    .size([width, height]);

  // This was the old displayGroupAll function
  force.gravity(layoutGravity)
    .charge(function (d, i) { return (i ? 0 : -2000) })
    .friction(0.9)
    .on('tick', (function(e) {
      circles
        .each(this._clusterFn(10 * e.alpha * e.alpha))
        .each(this._collideFn(nodes, 0.5, maxRadius, padding, clusterPadding))
        .attr('transform', function(d) { return "translate(" + d.x + ", " + d.y + ")" })
    }).bind(this));

  force.start();
};

BubblesHelper._breakText = function(text, lineLength) {
  var words = text.split(' ');
  var line = '';
  var lines = [];

  if (!lineLength) {
    lineLength = 20;
  }

  for (var i = 0; i < words.length; i++) {
    let testLine = line + words[i] + ' ';
    if (testLine.length > lineLength) {
      lines.push(line);
      line = words[i] + ' ';
    } else {
      line = testLine;
    }
  }

  lines.push(line);

  return lines;
};


BubblesHelper._collideFn = function(nodes, alpha, maxRadius, padding, clusterPadding) {
  var quadtree = d3.geom.quadtree(nodes);

  return function(d) {
    var r = d.radius + maxRadius + Math.max(padding, clusterPadding);

    var nx1 = d.x - r;
    var nx2 = d.x + r;
    var ny1 = d.y - r;
    var ny2 = d.y + r;

    return quadtree.visit(function(quad, x1, y1, x2, y2) {
      if (quad.point && (quad.point !== d)) {
        var x = d.x - quad.point.x;
        var y = d.y - quad.point.y;
        var l = Math.sqrt(x * x + y * y);
        var z = (d.cluster === quad.point.cluster ? padding : clusterPadding);
        var r = d.radius + quad.point.radius + z;
        if (l < r) {
          l = (l - r) / l * alpha;
          d.x -= x *= l;
          d.y -= y *= l;
          quad.point.x += x;
          quad.point.y += y;
        }
      }
      return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
    });
  }
};

BubblesHelper._clusterFn = function(alpha) {
  return function(d) {
    if (d.cluster === d) {
      return;
    }

    var x = d.x - d.cluster.x;
    var y = d.y - d.cluster.y;
    var l = Math.sqrt(x * x + y * y);
    var r = d.radius + d.cluster.radius;

    if (l !== r) {
      l = (l - r) / l * alpha;
      d.x -= x *= l;
      d.y -= y *= l;
      d.cluster.x += x;
      d.cluster.y += y;
    }
  }
};

export default class Bubbles extends React.Component {
  componentDidMount() {
    BubblesHelper.create(this.getChartDOMNode(), this.props, this.getChartState());
  }

  componentDidUpdate() {
    BubblesHelper.update(this.getChartDOMNode(), this.props, this.getChartState());
  }

  getChartDOMNode() {
    return ReactDOM.findDOMNode(this);
  }

  getChartState() {
    return this.props.data;
  }

  componentWillUnmount() {
    BubblesHelper.destroy(this.findDOMNode());
  }

  render() {
    return (
      <div className="Bubbles"></div>
    );
  }
}
