
class Message
  constructor: (@attributes) ->

  get: (attr) ->
    @attributes[attr]

module.exports = Message
