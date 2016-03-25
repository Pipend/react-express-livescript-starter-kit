require! \../config.ls
{create-factory}:React = require \react
{render} = require \react-dom
require! \react-router
Router = create-factory react-router.Router
Route = create-factory react-router.Route
IndexRoute = create-factory react-router.IndexRoute
require! \./components/App.ls

render do
    Router do
        history: react-router.browser-history
        Route do
            name: \app
            path: \/
            component: App
            # IndexRoute component: require \./components/NormalRoute.ls
            Route name: \normal, path: \/normal component: require \./components/NormalRoute.ls
    document.get-element-by-id \mount-node