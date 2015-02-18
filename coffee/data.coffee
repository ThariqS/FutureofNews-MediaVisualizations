module.exports = {}

Trend = Backbone.Model.extend()

TrendList = Backbone.Collection.extend
  url: 'http://um.media.mit.edu:5005/trends'

  comparator: (obj) -> obj.get("headlines")?.length

  parse: (response) ->

    response.json_list.map (obj) ->
      {name:obj,headlines:window.News.get(obj)?.get("headlines")}


Entity = Backbone.Model.extend()
NewsList = Backbone.Collection.extend
  url: 'http://um.media.mit.edu:5005/'
  parse: (response) ->
    entities = []
    for story in response.json_list
      headlines = []
      headlines.push story.description
      headlines.push story.title
      for related_story in story.related
        headlines.push related_story.title

      for entity in story.entities
        entities.push
          name: entity.value
          id: entity.value
          headlines: headlines
    return entities



module.exports.fetchHeadlines = () =>
  news = new NewsList()
  news.fetch()
  return news

module.exports.fetchTrends = () =>
  trends = new TrendList()
  trends.fetch()
  return trends

module.exports.compareWords = (set1,set2) =>

  intersection = []

  for item in set1
    match = _.find set2, (item2) => return (item.text is item2.text)
    if match?
      intersection.push item
      item.matched = true
      match.matched = true

  return intersection
