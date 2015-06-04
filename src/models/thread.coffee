class Thread
  messages: []
  add: (message)->
    @messages.push(message)

module.exports = Thread
