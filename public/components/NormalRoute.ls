{create-class, DOM:{div, button}}:React = require \react

module.exports = create-class do

    display-name: \Normal

    # render :: () -> ReactElement
    render: ->
        div null, 
            
            # REFRESH
            button do
                on-click: ~> 
                    fetch \/api/normal?limit=500
                        .then (.json!) 
                        .then (numbers) ~> 
                            @set-state {numbers}

                \refresh
            
            # NUMBERS
            div do 
                class-name: \numbers
                JSON.stringify @state.numbers


    # get-initial-state :: () -> UIState
    get-initial-state: -> 
        numbers: []