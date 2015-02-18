var restify = require('restify');
global._ = require('underscore');
var sqlite3 = require('sqlite3').verbose();

function getUserHome() {
  return process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
}

var db = new sqlite3.Database(process.env.HOME+'/Library/Application Support/Google/Chrome/Default/History');

port = (process.env.PORT || 8081);

var server = restify.createServer({
  name: 'myapp',
  version: '1.0.0'
});
server.use(restify.acceptParser(server.acceptable));
server.use(restify.queryParser());
server.use(restify.bodyParser());

server.get('/results', function (req, res, next) {

    db.all("SELECT visits.id,urls.url,urls.title,visits.from_visit,visits.transition FROM visits,urls WHERE urls.id = visits.url;", function(err, rows) {


      original_rows = rows;


      sites = ['newyorktimes.com','cnn.com','huffingtonpost.com','nytimes.com','theguardian.com',
      'forbes.com','bbc.com','bbc.co.uk','wsj.com','foxnews.com','bloomberg.com','reuters.com',
      ,'reuters.com','nbcnews.com','cnbc.com','nypost.com','yahoo.com','espn','washingtonpost.com','newyorker.com','comingoffaith.com','theverge.com','techcrunch.com'];

      sources = ['facebook.com','twitter.com','google.com']

      function extractDomain(url) {
          var domain;
          if (url.indexOf("://") > -1) {
              domain = url.split('/')[2];
          } else {
              domain = url.split('/')[0];
          }
          domain = domain.split(':')[0];
          return domain;
      }

      function searchForString(str,arr){
        news_site = arr.reduce(function(previousValue, currentValue, index, array) {
          if (previousValue != undefined){
            return previousValue;
          } else if (str.indexOf(array[index]) != -1) {
            return array[index];
          }
        },undefined);

        if (news_site){
          return true;
        } else{
          return false;
        }

      }

      news_results = _.filter(rows, function (row){
        url = row.url;
        news_site = sites.reduce(function(previousValue, currentValue, index, array) {
          if (previousValue != undefined){
            return previousValue;
          } else if (url.indexOf(array[index]) != -1) {
            return array[index];
          }
        },undefined);

        row.site = news_site;

        if (news_site){
          return true;
        } else{
          return false;
        }
      });

      traceVisit = function(visit,count,original_domain) {

        domain = extractDomain(visit.url);

        if (domain.indexOf('facebook') != -1 || domain.indexOf('fb.me') != -1) {
          return 'facebook';
        }

        if (domain.indexOf('t.co') != -1 || domain.indexOf('twitter.com') != -1) {
          return 'twitter';
        }

        if (visit.from_visit == 0 || count > 100) {
          if (visit.transition == 2684354560) {
            return 'link';
          } else{
            return domain;
          }
        }

        former_visit = _.find(rows, function(v){ return (visit.from_visit == v.id); });

        former_domain = extractDomain(former_visit.url)

        if (former_visit) {
          return traceVisit(former_visit,count+1,original_domain);
        } else{
          if (visit.transition == 2684354560) {
            return 'link';
          } else{
            return domain;
          }
        }
      }

      //sources = _.map(news_results, function(v){ return traceVisit(v,0,null); });

      sources = _.map(news_results, function(v){
        source = traceVisit(v,0,null);

        if (searchForString(source,sites) == true){
          source = 'news'
        }
        v.source = source;
        return v;
      });


      grouped_visits = _.groupBy(news_results, function(v){ return v.site; });
      grouped_sources = _.groupBy(sources, function(v){ return v.source; });

      console.log("RETURNED ALL RESULTS");

      res.send(grouped_sources);
    });

  return next();
});





server.get(/.*/, restify.serveStatic({
    'directory': 'public',
    'default': 'index.html'
 }));

server.listen(port, function () {
  console.log('%s listening at %s', server.name, server.url);
});
