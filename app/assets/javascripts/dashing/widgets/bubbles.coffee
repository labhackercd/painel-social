#= require CustomTooltip
#= require d3.legend
#= require spinning_widget

class Dashing.Bubbles extends Dashing.WidgetWithSpinner

  showOrHideSpinner: ->
    if not @get('items')
      @show_spinner()
    else
      @hide_spinner()

  @::on 'viewDidAppear', ->
    @showOrHideSpinner()

  @::on 'data', ->
    @data = @get('items') || []
    @labels = @get('labels') || []
    @fill_colors = @get('fill_colors')
    @min_radius = @get('min_radius')
    @max_radius = @get('max_radius')

    # XXX Por algum motivo desconhecido, tentar renderizar as bolhas
    # enquanto a página ainda não foi montada resulta em toda sorte
    # de inconsistências incompreensíveis. Para evitar isso, usamos
    # aqui o famoso hack do `setTimeout` na primeira renderização
    if !@didRenderOnce
      render = () =>
        @didRenderOnce = true
        setTimeout(@renderBubbles.bind(@), 600)
    else
      render = @renderBubbles

    # Aqui, evitamos que as bolhas sejam renderizadas antes do
    # widget ser incluído no DOM.
    if @isInDOM
      render()
    else
      @on 'viewDidAppear', ->
        render()

  renderBubbles: ->

    @showOrHideSpinner()

    if not (@width or @height)
      cur = $(@node)

      while (cur[0].tagName != "LI")
        cur = cur.parent()
        
      @container = cur
      
      @width = (Dashing.widget_base_dimensions[0] * @container.data("sizex")) + Dashing.widget_margins[0] * 2 * (@container.data("sizex") - 1)
      @height = (Dashing.widget_base_dimensions[1] * @container.data("sizey")) + Dashing.widget_margins[0] * 2 * (@container.data("sizey") - 1)

    # Remove previous word cloud if necessary
    $(@node).find("svg").remove()

    if (@force)
      @force.stop()

    # locations the nodes will move towards depending on which view is
    # currently being used
    @center = {x: @width / 2, y: @height / 2}

    @tooltip = CustomTooltip(@container, "bubbles_tooltip", 240)
    
    # used when setting up force and moving around nodes
    @layout_gravity = 0.08
    @damper = 0.1
    @max_clusters = 10
    @word_width = 10

    # padding between same-color circles
    @padding = 1.5 

    # separation between different-color circles
    @cluster_padding = 6

    # these will be set in create_nodes and create_vis
    @vis = null
    @nodes = []
    @clusters = new Array(@max_clusters)

    @force = null
    @circles = null

    # nice looking colors - no reason to buck the trend
    # @fill_colors = ["#ff7f0e", "#1f77b4", "#2ca02c", "#bcbd22", "#9467bd", "#8c564b", "#e377c2", "#7f7f7f", "#d62728", "#17becf"]
    # @fill_colors = ["#37a000", "#2074a8", "#fa8100", "yellow", "black"]
    # @fill_colors = d3.scale.category20();
    # @fill_color = d3.scale.ordinal()
    #     .domain(["foo", "bar", "baz"])
        # .range(colorbrewer.RdBu[9]);
    # @fill_color = colorbrewer.RdBu[9];
    # @fill_color = d3.scale.ordinal()
    #   .domain(["low", "medium", "high"])
    #   .range(["#0692e3", "#beccae", "#7aa25c"]);

    # use the max total_amount in the data as the max in the scale's domain

    max_amount = d3.max(@data, (d) -> parseInt(d.value))
    @radius_scale = d3.scale.pow()
      .exponent(0.5)
      .domain([0, max_amount])
      .range([@min_radius, @max_radius])
      
    
    @create_nodes()
    @create_vis()

    @start()
    @display_group_all()

  # create node objects from original data
  # that will serve as the data behind each
  # bubble in the vis, then add each node
  # to @nodes to be used later
  create_nodes: () =>
    @data.forEach (d) =>

      node = {
        id: d.label
        label: d.label
        radius: @radius_scale(parseInt(d.value)) * (@width/600)
        value: d.value
        cluster: d.categoria
        tooltip: d.tooltip
        x: Math.cos(d.categoria / @max_clusters * 2 * Math.PI) * 400 + @width / 2 + Math.random()
        y: Math.cos(d.categoria / @max_clusters * 2 * Math.PI) * 400 + @height / 2 + Math.random()
      }
      
      @clusters[d.categoria] = node  if not @clusters[d.categoria] or (d.r > @clusters[d.categoria].radius)
      
      @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value

  # create svg at vis and then create circle representation for each node
  create_vis: () =>
    @vis = d3.select("." + @id).append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("id", "svg_vis")

    #### KLUDGE to add labels
    if @labels?.length
      @labels_elements = @vis.selectAll("g")
        .data(@labels)
        .enter()
        .append("g")
        .attr("data-legend", (d) -> d["name"] if d?)
        .attr("data-legend-color", (d) -> d["color"] if d?)
        # .text((d) -> d)

      legend = @vis
        .append("g")
        .attr("class", "legend")
        .attr("transform", "translate(50,100)")
        .style("font-size", "12px")
        .call(d3.legend)

      setTimeout (->
        legend.style("font-size", "16px").attr("data-style-padding", 10).call d3.legend
      ), 1000

    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    widget = this

    node = @circles.enter().append("g")
      .attr("class", "node")
      .on("mouseover", (d, i) -> widget.showDetails(d, i))
      .on("mouseout", (d, i) -> widget.hideDetails(d, i))

    node.append("circle")
      .attr("r", 0)
      .attr("fill", (d) => @fill_colors[d.cluster])
      .attr("stroke-width", 4)
      .attr("stroke", (d) => d3.rgb(@fill_colors[d.cluster]).darker(0.4))
      .attr("id", (d) -> "bubble_#{d.id}")
      .attr("stroke-position", "10px")
      
    fo = node.append('foreignObject')
      .attr(
        x: (d, i) ->
          -d.radius + 5
        y: 0
        width: (d, i) ->
          d.radius * 2 - 10
        height: (d, i) ->
          d.radius * 2 - 10
      )
      
    topicLabel = fo.append('xhtml:div').attr('class', 'topicLabel').attr('pointer-events': 'none')
    
    text = topicLabel.append('xhtml:div').text((d, i) ->
      d.label
    ).attr(
      width: 'auto'
      height: 'auto').attr('text-anchor': 'middle').style(
      fill: '#30524d'
      'text-align': 'center').style('font-size', (d, i) ->
      String(d.radius / 4) + 'px'
    )

    topicLabel.style display: (d, i) ->
      rect = d3.select(this).select('div').node().getBoundingClientRect()
      if d.r * 2 < 100
        d.label = false

        ###return 'none'###

      else
        d.label = true

        ###return 'block'###

      return
    
    
    fo.each (d, i) ->
      rect = d3.select(this).select('div').node().getBoundingClientRect()
      height = String(-(rect.height / 2))
      @setAttribute 'y', height
      return
      
#    node.append("text")
#      .style("text-anchor", "middle")
#      .attr("transform", (d) -> "translate(0," + -10 * d.radius / 90 + ")")
#      # .style("dy", ".2em")
#      # .style("font-size", (d) -> if d.radius < 90 then 18 * d.radius / 90 + "px" else  "18px")
#      .style("font-size", (d) -> 18 * d.radius / 90 + "px" )
#      .style("font-weight", "600")
#      # .attr("stroke", "#000000")
#      # .attr("stroke-width", "1")
#      .attr("fill", "#000000")
#      .text((d) -> d.label)



    # Fancy transition to make bubbles appear, ending with the
    # correct radius
    @circles.transition().duration(500).delay((d, i) ->
      i * 5
    ).select("circle").attr("r", (d) -> d.radius)

  # Starts up the force layout with the default values
  start: ->
    @force = d3.layout.force()
      .nodes(@nodes)
      .size([@width, @height])

  # Sets up force layout to display
  # all nodes in one circle.
  display_group_all: () =>
    @force.gravity(@layout_gravity)
      .charge((d, i) -> if i then 0 else -2000)
      .friction(0.9)
      .on "tick", (e) =>
        # BEGIN 2
        @circles
          .each(@cluster(10 * e.alpha * e.alpha))
          .each(@collide(.5))
          .each(@ensureInsideBoundaries)
          .attr("transform", (d) -> "translate("+d.x+","+d.y+")")
        # END 2
    @force.start()
  
  # Ensure that the circles are within the SVG's boundaries,
  # i.e. they won't go off screen
  ensureInsideBoundaries: (d) =>
    d.x  = Math.max(d.radius, Math.min(@width - d.radius, d.x));

  # This is for simulation 2
  collide: (alpha) =>
    quadtree = d3.geom.quadtree(@nodes)
    me = this
    (d) ->
      r = d.radius + @max_radius + Math.max(@padding, @cluster_padding)
      nx1 = d.x - r
      nx2 = d.x + r
      ny1 = d.y - r
      ny2 = d.y + r
      quadtree.visit (quad, x1, y1, x2, y2) ->
        if quad.point and (quad.point isnt d)
          x = d.x - quad.point.x
          y = d.y - quad.point.y
          l = Math.sqrt(x * x + y * y)
          r = d.radius + quad.point.radius + ((if d.cluster is quad.point.cluster then me.padding else me.cluster_padding))
          if l < r
            l = (l - r) / l * alpha
            d.x -= x *= l
            d.y -= y *= l
            quad.point.x += x
            quad.point.y += y
        x1 > nx2 or x2 < nx1 or y1 > ny2 or y2 < ny1

  # This is for simulation 2
  cluster: (alpha) =>
    me = this
    (d) ->
      cluster = me.clusters[d.cluster]
      return  if cluster is d
      x = d.x - cluster.x
      y = d.y - cluster.y
      l = Math.sqrt(x * x + y * y)
      r = d.radius + cluster.radius
      unless l is r
        l = (l - r) / l * alpha
        d.x -= x *= l
        d.y -= y *= l
        cluster.x += x
        cluster.y += y
  
  
  # Moves all circles towards the @center
  # of the visualization
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (@center.y - d.y) * (@damper + 0.02) * alpha
  
  showDetails: (data, i) ->
    content = "#{data.tooltip}"
    @tooltip.showTooltip(content, d3.event) if data.tooltip isnt `undefined`
  
  
  hideDetails: (data, i) ->
    @tooltip.hideTooltip()
