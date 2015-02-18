
#Just putting backbone/jquery boilerplate in for now
window.$ = window.jQuery = require('jquery')
window._ = require('underscore')
window.Backbone = require('backbone')
window.Backbone.$ = $
window.d3 = require('d3')

window.Wave = require('loading-wave')

window.highlight = require('em-highlight')

window.App =
  Constants: undefined
  Draw: require('./draw')
  Data: require('./data')
  Sources: require('./sources')
  Views: require('./views')
  Loading:
    start: () ->
      App.Loading.wave.start()
      $('.loading-wave').show()
      $('.content-body').hide()
    stop: () ->
      App.Loading.wave.stop()
      $('.loading-wave').hide()
      $('.content-body').show()

    wave:  Wave({
      width: 100,
      height: 100,
      n: 10,
      color: 'steelblue'
    })


$(document).ready ->

  $('.loading-wave').append(App.Loading.wave.el)
  $('.intro').hide()
  App.Loading.start()

  window.News = App.Data.fetchHeadlines()

  window.News.on "sync", () =>
    window.trends = App.Data.fetchTrends()
    selector = new App.Views.TrendSelector(trends)
    selector.listen()
    App.Loading.stop()
    $('.intro').css( "display", "inline-block")

  #fetchQuery("Kenya")

  return

window.fetchQuery = (query) =>

  $('.intro').hide()

  App.Loading.start()

  App.Sources.fetch query,({twitter_words,news_words}) =>

    intersect = App.Data.compareWords(news_words,twitter_words)

    news_words = _.filter news_words, (obj) -> not obj.matched
    twitter_words = _.filter twitter_words, (obj) -> not obj.matched

    App.Draw.drawCloud(news_words,'.news-cloud',false)
    App.Draw.drawCloud(twitter_words,'.twitter-cloud',true)

    App.Draw.drawIntersection(intersect,".intersection-cloud")

    App.Loading.stop()

    $('.wordcloud text').click (e) ->
      elem = $(e.currentTarget)
      query = elem.text()

      count = elem.parents('.news-cloud').length

      console.log ("COUNT IS #{count}")

      if count > 0
        source = 'News'
      else
        source = 'Twitter'

      lines = App.Sources.search(query,source)
      lines = _.first(lines,8)
      return true if lines.length is 0

      lines = lines.map (line) -> "<p>#{line}</p>"
      content = lines.join(' ')

      content = highlight.find(content,query)

      drop = new Drop
        target: e.currentTarget
        content: content
        position: 'bottom right'
        openOn: 'click'
        classes: 'drop-theme-arrows-bounce bubble-content'
        remove: true

      drop.open()

      return true


    return

    return
