#= require ./vendor/date
#= require ./vendor/jquery
#= require ./vendor/underscore
#= require ./vendor/backbone
#= require ./vendor/codemirror
#= require ./vendor/codemirror-javascript

#= require ./rpn
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./templates
#= require_tree ./views
#= require_tree ./routers

$ ->
  $('div[role="main"] a, #logo a').live 'click', (event) ->
    href = $(this).attr('href')
    event.preventDefault()
    window.app.navigate(href, {trigger: true})

  RPN.devices = new RPN.Collections.Devices
  RPN.devices.fetch(success: RPN.initialize)