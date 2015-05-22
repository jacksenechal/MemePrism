{ log, p } = require 'lightsaber'
GoogleGroup = require '../adaptor/google_group'

class Prism
  read: (config) ->
    if config.googleGroup
      (new GoogleGroup).read config.googleGroup

module.exports = Prism
