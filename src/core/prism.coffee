{ log, p } = require 'lightsaber'
Wordpress = require '../adaptor/wordpress'

class Prism
  read: (config) ->
    if config.googleGroup
      (new GoogleGroup).read config.googleGroup

  write: (config) ->
    if config.wpUrl and config.wpUsername and config.wpPassword
      (new Wordpress).write config

module.exports = Prism
