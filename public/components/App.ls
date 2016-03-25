{create-class, create-factory, DOM:{div}}:React = require \react
Link = create-factory (require \react-router).Link

module.exports = create-class do

    display-name: \App

    # render :: a -> ReactElement
    render: ->
        div class-name: \app,

            # MENU
            div class-name: \menu,
                Link to: \/normal, \normal

            # ROUTES
            div class-name: \route, @props.children

            # BUILDING
            if @state.building
                div {class-name: \building}, \Building...

    # get-initial-state :: a -> UIState
    get-initial-state: ->
        building: false

    # component-did-mount :: a -> Void
    component-will-mount: !->
        if window.location.hostname in <[localhost 127.0.0.1]>
            (require \socket.io-client) \http://localhost:8601
                ..on \build-start, ~> @set-state building: true
                ..on \build-complete, -> window.location.reload!