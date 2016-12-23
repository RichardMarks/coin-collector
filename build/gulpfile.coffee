gulp = require 'gulp'
coffeeify = require 'gulp-coffeeify'
gutil = require 'gulp-util'
path = require 'path'
less = require 'gulp-less'

config =
  app_path: 'src'
  web_path: 'dist'
  assets_path: 'assets'
  app_main_file: 'app.js'
  css_main_file: 'app.css'
  styles_main_file: 'style/app.less'

gulp.task 'coffee', ->
  options =
    options:
      debug: true,
      paths: [ "#{__dirname}/node_modules", "#{__dirname}/src/coffee" ]
  gulp.src "#{config.app_path}/**/*.coffee"
  .pipe coffeeify options
  .pipe gulp.dest "#{config.web_path}/js"
  .on 'error', gutil.log

gulp.task 'less', ->
  gulp.src config.styles_main_file
  .pipe less paths: [ path.join(__dirname) ]
  .pipe gulp.dest "#{config.web_path}/css"
  .on 'error', gutil.log

gulp.task 'assets', ->
  gulp.src "#{config.assets_path}/**"
  .pipe gulp.dest "#{config.web_path}/assets"
  .on 'error', gutil.log

gulp.task 'index', ->
  gulp.src './index.html'
  .pipe gulp.dest "#{config.web_path}"
  .on 'error', gutil.log

gulp.task 'build', ['index', 'coffee', 'less', 'assets']
gulp.task 'default', ['build', 'watch']

gulp.task 'watch', ->
  gulp.watch "./index.html", ['index']
  gulp.watch "#{config.app_path}/**/*.coffee", ['coffee']
  gulp.watch "#{config.app_path}/**/*.(less)", ['less']
  gulp.watch "#{config.assets_path}", ['assets']
