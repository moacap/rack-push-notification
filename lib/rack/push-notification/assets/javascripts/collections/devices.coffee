class RPN.Collections.Devices extends Backbone.Paginator.requestPager
  model: RPN.Models.Device

  paginator_core:
    type: 'GET'
    dataType: 'json'
    url: '/devices?'

  paginator_ui:
    firstPage: 1,
    currentPage: 1,
    perPage: 3

  server_api:
    'limit': ->
      @perPage
    'offset': ->
      (@currentPage - 1) * @perPage

  parse: (response) ->
    console.log(response)
    @totalPages = Math.ceil(response.total / @perPage)
    response.devices

  comparator: (database) ->
    database.get('token')
