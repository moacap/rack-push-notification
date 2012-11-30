class RPN.Views.Devices extends Backbone.View
  template: JST['templates/devices']
  el: "[role='main']"

  events:
    'click a.previous': 'gotoPrevious'
    'click a.next': 'gotoNext'
    'click a.page': 'gotoPage'

  initialize: ->
    @collection.on 'reset', =>
      @render()

  render: ->
    console.log(@collection)
    @$el.html(@template(devices: @collection))
    @

  gotoPrevious: (e) ->
    e.preventDefault()
    @collection.goTo(@collection.currentPage - 1) unless @collection.currentPage == @collection.firstPage

  gotoNext: (e) ->
    e.preventDefault()
    @collection.goTo(@collection.currentPage + 1) unless @collection.currentPage == @collection.totalPages

  gotoPage: (e) ->
    e.preventDefault()
    page = $(e.target).text()
    @collection.goTo(page)