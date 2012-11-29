class RPN.Routers.Root extends Backbone.Router
  el:
    "div[role='container']"

  initialize: (options) ->
    @views = {}
    super

  routes:
    '':         'index'
    'compose':  'compose'
    'compose/': 'compose'

  index: ->
    RPN.devices.fetch()
    @views.devices ||= new RPN.Views.Devices(collection: RPN.devices)
    @views.devices.render()

  compose: ->
    @views.compose ||= new RPN.Views.Compose()
    @views.compose.render()