class RPN.Views.Compose extends Backbone.View
  template: JST['templates/compose']
  el: "[role='main']"

  events:
    'keyup textarea': 'updatePreview'

  initialize: ->
    window.setInterval(@updateTime, 10000)

  render: ->
    @$el.html(@template())

    @editor = CodeMirror.fromTextArea(document.getElementById("payload"), {
      mode: "application/json",
      theme: "solarized-dark",
      tabMode: "indent",
      lineNumbers : true,
      matchBrackets: true
    })

    this.updatePreview()
    this.updateTime()

    @

  updatePreview: ->
    try
      json = $.parseJSON(@editor.getValue())
      console.log(json)
      if alert = json.aps.alert
        $(".preview p").text(alert)
    
    catch error
      $(".alert strong").text(error.name)
      $(".alert span").text(error.message)
    finally
      if alert? and alert.length > 0
        $(".notification").show()
        $(".alert").hide()
      else
        $(".notification").hide()
        $(".alert").show()

  updateTime: ->
    $time = $("time")
    $time.attr("datetime", Date.now().toISOString())
    $time.find(".time").text(Date.now().toString("HH:mm"))
    $time.find(".date").text(Date.now().toString("dddd, MMMM d"))

