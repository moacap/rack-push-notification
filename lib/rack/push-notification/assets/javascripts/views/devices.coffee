class RPN.Views.Devices extends Backbone.View
  template: JST['templates/devices']
  el: "section[role='main']"

  initialize: ->
    @collection.on 'reset', =>
      @render()

  render: ->
    @$el.html(@template(devices: @collection.toJSON()))
    @
