
var gulp = require('gulp');
var coffee = require('gulp-coffee');
var log  = require('gulp-util').log;
var concat = require('gulp-concat');
var browserify = require('browserify');
var source = require('vinyl-source-stream');
var nodemon = require('gulp-nodemon');


gulp.task('browserify', function() {

    bundler = browserify({
      entries: ['./coffee/app.coffee'],
      extensions: ['.coffee'],
      debug: true
    });

    return bundler.bundle().pipe(source('main.js')).pipe(gulp.dest('./public/js'));

});

gulp.task('server', function () {
  nodemon({ script: 'server.js'})
    .on('restart', function () {
      console.log('restarted!')
    })
});


gulp.task('watch', function() {
  return gulp.watch('./coffee/*.coffee', ['browserify']);
});

gulp.task('default', ['browserify', 'watch']);
