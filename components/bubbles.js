function Bubbles(el, data) {
  this.layoutGravity = 0.08;

  // padding between circles of the same color
  this.padding = 1.5;

  // separation between circles of different colors
  this.clusterPadding = 6;

  this.doTheThing(el, data);
}

Bubbles.prototype.doTheThing = function(el, data) {
  var self = this;

  var items = data['items'];

  var fillColors = data['fill_colors'];
  var minRadius = data['min_radius'];
  var maxRadius = data['max_radius'];

  var width = 1200;
  var height = 768;
  var maxClusters = 10;

  // TODO tooltips

  // Create the visualization
  var svg = d3.select(el)
    .append('svg')
    .attr('class', 'd3')
    .attr('width', width)
    .attr('height', height);

  // use the max total_amount in the data as the max in the scale's domain
  // FIXME XXX Why is it a `parseInt` here?
  var domainMax = d3.max(items, function(d) { return parseInt(d.value) });

  // Create the nodes
  var radiusScale = d3.scale.pow()
    .exponent(0.5)
    .domain([0, domainMax])
    .range([minRadius, maxRadius]);

  var nodes = _.map(items, function(d) {
    return {
      id: d.label,
      label: d.label,
      label_lines: self._breakText(d.label),
      radius: radiusScale(parseInt(d.value)),
      value: d.value,
      category: d.categoria,
      tooltip: d.tooltip,
      fillColor: fillColors[d.categoria],
      x: Math.cos(d.categoria / maxClusters * 2 * Math.PI) * 400 + width / 2 + Math.random(),
      y: Math.cos(d.categoria / maxClusters * 2 * Math.PI) * 400 + self.height / 2 + Math.random()
    };
  });

  // Separate the nodes in clusters
  {
    var clusters = new Array(maxClusters);

    _.each(nodes, function(d) {
      if (!clusters[d.category] || (d.r > clusters[d.category].radius)) {
        clusters[d.category] = d;
      }
    });

    _.each(nodes, function(d) {
      d.cluster = clusters[d.category];
    });
  }

  // XXX Why exactly do we need to sort nodes?
  nodes = _.sortBy(nodes, function(d) { return d.value * (-1) });

  // Place the nodes in the graph as circles
  var circles = svg
    .selectAll('circle')
    .data(nodes, function(d) { return d.id });

  var node = circles.enter().append('g')
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
  force.gravity(this.layoutGravity)
    .charge(function (d, i) { return (i ? 0 : -2000) })
    .friction(0.9)
    .on('tick', function(e) {
      circles
        .each(self.clusterFn(10 * e.alpha * e.alpha))
        .each(self.collideFn(nodes, 0.5, self.maxRadius, self.padding, self.clusterPadding))
        .attr('transform', function(d) { return "translate(" + d.x + ", " + d.y + ")" })
    });

  force.start();
};

Bubbles.prototype._breakText = function(text, lineLength) {
  var words = text.split(' ');
  var line = '';
  var lines = [];

  if (!lineLength) {
    lineLength = 20;
  }

  for (var i = 0; i < words.length; i++) {
    testLine = line + words[i] + ' ';
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


Bubbles.prototype.collideFn = function(nodes, alpha, maxRadius, padding, clusterPadding) {
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

Bubbles.prototype.clusterFn = function(alpha) {
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
