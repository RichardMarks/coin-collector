gulp = require 'gulp'
browserify = require 'browserify'
gutil = require 'gulp-util'
path = require 'path'
# needed to rename output file
source = require 'vinyl-source-stream'
# needed to transform browserify to stream
buffer = require 'vinyl-buffer'

sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'

config =
  src: path.resolve './src'
  dist: path.resolve './dist'
  assets: path.resolve './assets'
  main: 'main.js'
  node: path.resolve './node_modules'

gulp.task 'coffee', ->
  DEBUG = true
  cfg =
    entries: ["#{config.src}/index.coffee"]
    debug: DEBUG
    extensions: ['.coffee']
    transform: ['coffeeify']
  ugly =
    debug: DEBUG
    options: 
      sourceMap: true
  browserify cfg
  .bundle()
  .pipe source config.main
  .pipe buffer()
  .pipe sourcemaps.init loadMaps: true, debug: DEBUG
  .pipe uglify ugly
  .pipe sourcemaps.write './'
  .pipe gulp.dest config.dist
  .on 'error', gutil.log

gulp.task 'assets', ->
  gulp.src "#{config.assets}/**"
  .pipe gulp.dest "#{config.dist}/assets"
  .on 'error', gutil.log

gulp.task 'index', ->
  gulp.src './index.html'
  .pipe gulp.dest "#{config.dist}"
  .on 'error', gutil.log

gulp.task 'build', ['coffee', 'assets', 'index']

gulp.task 'watch', ->
  gulp.watch "./index.html", ['index']
  gulp.watch "#{config.src}/**/*.coffee", ['coffee']
  gulp.watch "#{config.assets}", ['assets']

gulp.task 'default', ['build', 'watch']
