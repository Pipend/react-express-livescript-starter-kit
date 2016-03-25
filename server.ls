require! \body-parser
{http-port}:config = require \./config
require! \express
{map, each, foldl} = require \prelude-ls

app = express!
    ..set \views, __dirname + \/
    ..engine \.html, (require \ejs).__express
    ..set 'view engine', \ejs
    ..use body-parser.json!
    ..use body-parser.urlencoded {extended: false}
    ..use \/node_modules, express.static "#__dirname/node_modules"
    ..use \/public, express.static "#__dirname/public"

(require \./routes)! |> each ({paths, request-handler}) !->
    paths |> each ({method, optional-params or {}, patterns}?) !->
        if patterns
            patterns |> each (pattern) -> 
                app[method] pattern, request-handler

        else
            app[method] request-handler

app.listen http-port
console.log "express listening on port #{http-port}"