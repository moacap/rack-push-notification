class RPN.Collections.Devices extends Backbone.Collection
  url: "/devices"
  model: RPN.Models.Device

  comparator: (database) ->
    database.get('token')
