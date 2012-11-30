class RPN.Views.Devices extends Backbone.View
  template: JST['templates/devices']
  el: "[role='main']"

  initialize: ->
    @collection.on 'reset', =>
      @render()

  render: ->
    @$el.html(@template(devices: @collection.toJSON()))
    @
