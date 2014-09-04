#= require d3.layout.cloud
#= require spinning_widget

class Dashing.Wordcloud extends Dashing.WidgetWithSpinner

  didRenderOnce: false

  @::on 'data', ->
    # XXX Por algum motivo desconhecido, tentar renderizar o widget
    # enquanto a página ainda não foi montada resulta em toda sorte
    # de inconsistências incompreensíveis. Eu acredito sinceramente
    # que isso tem a ver com a complexidade do algoritmo de criação
    # das bolhas, que acaba sobrecarregando a máquina virtual de JS
    # do browser e causando problemas na interação com outros
    # componentes utilizados na página. Para evitar isso, usamos uns
    # timeouts.
    if !@didRenderOnce
      render = () =>
        @didRenderOnce = true
        setTimeout(@renderWordCloud.bind(@), 600)
    else
      render = @renderWordCloud.bind(@)

    # Aqui, evitamos que as bolhas sejam renderizadas antes do
    # widget ser incluído no DOM.
    if @isInDOM
      render()
    else
      @on 'viewDidAppear', ->
        render()

  @::on 'viewDidAppear', ->
    @show_spinner() if not @hasData

  renderWordCloud: ->
    # Set up some variables
    cur = $(@node)
    while (cur[0].tagName != "LI")
      cur = cur.parent()
      
    container = cur

    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))

    # Remove previous word cloud if necessary
    if (@cloud)
      @cloud.stop()
      $(@node).find("svg").remove()

    # Should we draw a new cloud or show the spinner?
    wordList = @get('value') || []
    if not wordList?.length
      return
    else
      @hide_spinner()

    # Fill colors
    # fill = d3.scale.category20();
    # fill = d3.scale.linear().domain([0,1,2,3,4,5,6,10,15,20,100]).range(["#222", "#333","#444", "#555", "#666", "#777", "#888", "#999", "#aaa", "#bbb", "#ccc", "#ddd"])
    fill = d3.scale.linear().domain([0,1,2]).range(["#222", "#333","#444"])
    # fill = d3.scale.linear().domain([0,1,2,3,4,5,6,10,15,20,100]).range(["#ddd", "#ccc", "#bbb", "#aaa", "#999", "#888", "#777", "#666", "#555", "#444", "#333", "#222"])
    
    selector = "." + @id
    draw = (words) -> d3.select(selector)\
      .append("svg")\
      .attr("width", width)\
      .attr("height", height)\
      .attr("class", "wordcloud")\
      .append("g")\
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")\
      .selectAll("text")\
      .data(words)\
      .enter()\
      .append("a")\
      .attr("xlink:href", (d) -> d.link)\
      .attr("xlink:target", "_blank")\
      .append("text")\
      .style("font-size", (d) -> d.size + "px")\
      .style("font-weight", "600")\
      # .style("font-family", "Impact")\  # (1)
      .style("fill", (d, i) -> fill(i))\
      .attr("text-anchor", "middle")\   # (2)
      .attr("transform", (d) -> "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")")\
      .text((d) -> d.text)

    @cloud = d3.layout.cloud()\
      .size([width, height])\
      .words(wordList)\
      .padding(5)\   # (3)
      # .rotate(() -> ~~(Math.random() * 2) * 30; )\ # (4)
      .rotate(() -> ~~(Math.random() * 2) * 90; )\ # (4)
      .rotate(0)\ # (4)
      .font("Impact")\ # (1)
      .fontSize((d) -> d.size )\
      .on("end", draw)\
      .start()
