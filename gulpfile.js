const gulp = require('gulp');
const elm  = require('gulp-elm');
const uglify = require('gulp-uglify');
const rename = require('gulp-rename');

gulp.task('elm-init', elm.init);
 
gulp.task('elm', ['elm-init'], function(){
  return gulp.src('src/*.elm')
    .pipe(elm())
    .pipe(gulp.dest('dist/'));
});
 
gulp.task('make', ['elm-init'], function(){
  return gulp.src('demo/*.elm')
    .pipe(elm.bundle('demo.js'))
    .pipe(uglify())
    .pipe(rename({ suffix: '.min', }))
    .pipe(gulp.dest('javascripts/'));
});

gulp.task('debug', ['elm-init'], function(){
  return gulp.src('demo/*.elm')
    .pipe(elm.bundle('demo.js', { "debug" : true }))
    .pipe(uglify())
    .pipe(rename({ suffix: '.min', }))
    .pipe(gulp.dest('javascripts/'));
});