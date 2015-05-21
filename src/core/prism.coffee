{ log, p } = require 'lightsaber'

class Prism
  read: (config) ->
    if config.googleGroup
      log "Importing/updating Google Group: #{config.googleGroup}"

module.exports = Prism
