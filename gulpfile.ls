require! \browserify
require! \gulp
require! \gulp-nodemon
require! \gulp-if
require! \gulp-livescript
{instrument, hook-require, write-reports} = (require \gulp-livescript-istanbul)!
require! \gulp-mocha
require! \gulp-streamify
require! \gulp-stylus
require! \gulp-uglify
require! \gulp-util
require! \nib
{basename, dirname, extname} = require \path
require! \run-sequence
source = require \vinyl-source-stream
require! \watchify
{once} = require \underscore
config = require \./config.ls

io = null

# emit-with-delay :: String -> IO()
emit-with-delay = (event) ->
    if io
        <- set-timeout _, 0 
        io.emit event

# build styles in components
gulp.task \build:styles, ->
    gulp.src <[./public/index.styl]>
    .pipe gulp-stylus {
        use: nib!
        import: <[nib]>
        compress: config.gulp.minify
        "include css": true
    }
    .pipe gulp.dest \./public
    .on \end, -> emit-with-delay \build-complete if io

# watch styles in components
gulp.task \watch:styles, -> 
    gulp.watch <[./public/*.styl ./public/components/*.styl]>, <[build:styles]>

# create a browserify Bundler
# create-bundler :: [String] -> Bundler
create-bundler = (entries) ->
    bundler = browserify {} <<< watchify.args <<< debug: !config.gulp.minify
        ..add entries
        ..transform \liveify

# outputs a single javascript file (which is bundled and minified - depending on env)
# bundler :: Bundler -> {file :: String, directory :: String} -> IO()
bundle = (bundler, {file, directory}:output) ->
    bundler.bundle!
        .on \error, -> 
            gulp-util.log arguments
        .pipe source file
        .pipe gulp-if config.minify, (gulp-streamify gulp-uglify!)
        .pipe gulp.dest directory

# build-and-watch :: Bundler -> {file :: String, directory :: String} -> (() -> Void) -> (() -> Void) -> (() -> Void)
build-and-watch = (bundler, {file}:output, done, on-update, on-build) ->
    # must invoke done only once
    once-done = once done

    watchified-bundler = watchify bundler

    # build once
    bundle watchified-bundler, output

    watchified-bundler
        .on \update, -> 
            if on-update
                on-update!
            bundle watchified-bundler, output
        .on \time, (time) ->
            if on-build
                on-build!
            once-done!
            gulp-util.log "#{file} built in #{time / 1000} seconds"

index-ls = create-bundler [\./public/index.ls]
index-js = file: \index.js, directory: \./public/

gulp.task \build:scripts, ->
    bundle index-ls, index-js

gulp.task \build-and-watch:scripts, (done) ->
    build-and-watch do 
        index-ls
        index-js
        done
        -> emit-with-delay \build-start
        -> emit-with-delay \build-complete

gulp.task \dev:server, ->
    if config?.gulp?.reload-port
        io := (require \socket.io)!
            ..listen config.gulp.reload-port

    gulp-nodemon do
        exec-map: ls: \lsc
        ext: \ls
        ignore: <[gulpfile.ls README.md *.sublime-project public/* node_modules/* migrations/*]>
        script: \./server.ls

gulp.task \coverage, ->
    gulp.src <[./routes.ls]> # files which we want coverage report
    .pipe instrument!
    .pipe hook-require!
    .on \finish, ->
        gulp.src <[./test/index.ls]>
        .pipe gulp-mocha!
        .pipe write-reports!
        .on \finish, -> process.exit!

gulp.task \build, <[build:styles build:scripts]>
gulp.task \default, -> run-sequence do 
    <[
        build:styles 
        watch:styles 
        build-and-watch:scripts
    ]>
    \dev:server 