

module.exports.TrendSelector = class trendSelector extends Backbone.View

  initialize: (trends) =>
    @trends = trends
    @

  events:
    "click .trend-item": "clickTrend"

  listen: () =>
    @listenTo @trends,'sync',@attach
    @

  render: () =>

    @$el.html("<ul class='trends-list side-nav'></ul>")

    for trend in @trends.models
      @$('.trends-list').append("<li class='trend-item'><a href='#'>#{trend.get('name')}</a></li>")
    @$el

  attach: () =>
    $('.selector').append @render()

  clickTrend: (e) =>
    $('.news-cloud').empty()
    $('.twitter-cloud').empty()
    $('.intersection-cloud').empty()
    query = $(e.currentTarget).find('a').text()
    $('.query-text').text("#{query}")
    fetchQuery(query)
    @



###
class Selector extends Backbone.View

App.Data.fetch "Kenya",(words) ->
  App.Draw.drawCloud(words)
  return

App.Data.twitter "Kenya",(words) ->
  App.Draw.drawCloud(words)
  return
###
