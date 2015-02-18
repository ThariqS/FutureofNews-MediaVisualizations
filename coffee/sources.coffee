module.exports = {}

wf = require('word-freq')
twitter = require('twitter')
normalize = require('normalize-to-range')
variance = require('variance')
tokenizer = require('sbd')

Trend = Backbone.Model.extend()

Sources =
  Twitter: undefined
  News: undefined

module.exports.Sources = Sources

class Source

  text: undefined
  raw_lines: undefined

  constructor: () ->
    return

  fetch: ({query,text,threshold,callback}) =>
    @text = text.toLowerCase()
    words = @process
      query:query
      text: text
      threshold: threshold

    callback(words)
    @

  search: (query) =>
    query = query.toLowerCase()
    lines = _.filter @raw_lines, (line) -> (line.toLowerCase().indexOf(query) isnt -1)
    return lines

  process: ({query,text,threshold}) =>
    text = text.replace(/\@\S+/ig,"")
    text = text.replace(/\#\S+/ig,"")
    frequency = wf.freq(text,true,false)

    query = query.toLowerCase()
    blockers = ["http","https"]

    banned = blockers.concat(query.split(" "))

    words = []
    for k,v of frequency
      if v > 1 and k.length > 3 and k not in banned and k.indexOf("_") is -1
        words.push
          text: k
          size: v*5
          matched: false

    range = variance(words.map (word) -> word.size)
    words = normalize(words, 18, 35, 'size')
    words = _.sortBy words, (word) -> return word.size*-1
    words = _.first(words,30)

    return words

class TwitterSource extends Source

  fetch: ({query,callback}) =>
    $.getJSON "/twitter/#{query}", (tweets) =>

      @raw_lines = tweets.map (tweet) -> tweet.toLowerCase()
      super
        threshold: 5
        text: tweets.join(" ")
        query: query
        callback: callback
      @
    @

class NewsSource extends Source


  parseHeadlines: (keyword) =>
    entity = window.News.get(keyword)
    return "" if not entity?

    headlines = entity.get("headlines")
    return headlines.join(" ")


  fetch: ({query,callback}) =>

    url = "http://um-query.media.mit.edu/search/#{query}?segmentType=all"

    $.getJSON url, (data) =>
      transcript = data.results[0].transcript

      headlines = @parseHeadlines(query)
      sentences = tokenizer.sentences(transcript)

      text = transcript + @parseHeadlines(query)

      @raw_lines = sentences.concat(headlines)

      super
        threshold: 1
        text: text
        query: query
        callback: callback

      return

    return


module.exports.fetch = (query,callback) =>

  Sources.Twitter = new TwitterSource()
  Sources.News = new NewsSource()

  word_length = query.split(" ").length

  Sources.News.fetch
    query: query
    callback: (news_words) =>

      query_add = _.max news_words,(word) -> word.size
      twitter_query = query + " " + query_add.text

      Sources.Twitter.fetch
        query: twitter_query
        callback: (twitter_words) =>
          callback
            twitter_words: twitter_words
            news_words: news_words
          @
      @
  @

module.exports.search = (query,source) =>
  Sources[source].search(query)
