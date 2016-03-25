{map} = require \prelude-ls

module.exports = ->

    routes = 
        # STATIC
        *   paths:
                *   method: \get
                    patterns: <[/ /normal]>
                ...
            request-handler: (req, res) ->
                res.render \public/index.html

        # API
        *   paths:
                *   method: \get
                    patterns: <[/api/normal]>
                ...
            request-handler: (req, res, next) ->
                res.send do 
                    [0 til req.query.limit] |> map -> 
                        Math.floor Math.random! * 100