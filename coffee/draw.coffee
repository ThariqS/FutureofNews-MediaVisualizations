djb2 = (str) ->
  hash = 5381
  i = 0

  while i < str.length
    hash = ((hash << 5) + hash) + str.charCodeAt(i) # hash * 33 + c
    i++
  hash

window.hashStringToColor = (str) ->
  hash = djb2(str)
  r = (hash & 0xff0000) >> 16
  g = (hash & 0x00ff00) >> 8
  b = hash & 0x0000ff
  "#" + ("0" + r.toString(16)).substr(-2) + ("0" + g.toString(16)).substr(-2) + ("0" + b.toString(16)).substr(-2)





fill = d3.scale.category20()


module.exports = {}
module.exports.drawCloud = (words,elem,shifted=false) ->

  if shifted is true
    viewport = "-25 0 275 275"
    transform = "translate(130,150)"
  else
    viewport = "25 0 275 275"
    transform = "translate(130,150)"

  font = "'lucida grande','trebuchet ms',arial,helvetica,sans-serif"

  draw = (words) =>
    svg = d3.select(elem).append("svg").attr("class", "wordcloud").attr("viewBox", viewport).append("g").attr("transform",transform).selectAll("text").data(words).enter().append("text").style("font-size", (d) ->
      d.size + "px"
    ).style("font-family",font).style("fill", (d, i) ->
      #return window.hashStringToColor(d.text)
      if d.matched is true
        return "red"
      else
        return "rgb(100, 100, 100)"
      #return window.hashStringToColor(d.text)
    ).attr("text-anchor", "middle").attr("transform", (d) ->
      "translate(" + [
        d.x
        d.y
      ] + ")rotate(" + d.rotate + ")"
    ).text (d) ->
      d.text
    return

  d3.layout.cloud().size([
    225
    250
  ]).words(words).padding(5).rotate(->
    0
  ).font("Impact").fontSize((d) ->
    d.size
  ).on("end", draw).start()

module.exports.drawIntersection = (words,elem) ->

  viewport = "0 0 150 450"

  testdraw = (words) =>
    svg = d3.select(elem).append("svg").attr("class", "intersection").attr("viewBox", viewport).append("g").attr("transform", "translate(85,220)").selectAll("text").data(words).enter().append("text").style("font-size", (d) ->
      22 + "px"
    ).style("font-family", "Impact").style("fill", (d, i) -> return "purple"
    ).attr("text-anchor", "middle").attr("transform", (d) ->
      "translate(" + [
        d.x
        d.y
      ] + ")rotate(" + d.rotate + ")"
    ).text (d) ->
      d.text

    return

  d3.layout.cloud().size([
    75
    250
  ]).words(words).padding(5).rotate(->
    0
  ).font("Impact").fontSize((d) ->30
  ).on("end", testdraw).start()




#module.exports.drawClouds(twitter,news) ->
