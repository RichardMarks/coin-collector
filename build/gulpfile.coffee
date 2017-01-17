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

coffeelint = require 'gulp-coffeelint'
rimraf = require 'rimraf'

gwatch = require 'gulp-watch'
connect = require 'gulp-connect'

config =
  src: path.resolve './src'
  dist: path.resolve './dist'
  assets: path.resolve './assets'
  main: 'main.js'
  node: path.resolve './node_modules'
  port: 8000

gulp.task 'clobber', (onComplete) -> rimraf config.node, onComplete
gulp.task 'clean', (onComplete) -> rimraf config.dist, onComplete

gulp.task 'lint', ->
  gulp.src "#{config.src}/*.coffee"
  .pipe coffeelint()
  .pipe coffeelint.reporter()

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

gulp.task 'style', ->
  gulp.src './style.css'
  .pipe gulp.dest "#{config.dist}"
  .on 'error', gutil.log

gulp.task 'index', ->
  gulp.src './index.html'
  .pipe gulp.dest "#{config.dist}"
  .on 'error', gutil.log

gulp.task 'serve', ->
  DEBUG = true
  cfg =
    debug: DEBUG
    port: config.port
    livereload: true
    root: config.dist
  connect.server cfg

gulp.task 'livereload', ->
  gulp.src config.dist
  .pipe gwatch config.dist
  .pipe connect.reload()

gulp.task 'build', ['clean', 'lint', 'coffee', 'assets', 'style','index']

gulp.task 'watch', ->
  gulp.watch "./index.html", ['index']
  gulp.watch "./style.css", ['style']
  gulp.watch "#{config.src}/**/*.coffee", ['lint', 'coffee']
  gulp.watch "#{config.assets}", ['assets']

gulp.task 'default', ['build','serve','livereload', 'watch']
