{ log, p } = require 'lightsaber'
Wordpress = require '../adaptor/wordpress'
fs = require 'fs'
Email = require '../adaptor/email'
Message = require '../models/message'

class Prism
  read: (config, callback) ->
    if config.emailFile
      emailData = fs.readFileSync config.emailFile, encoding: 'utf8'
      email = (new Email).read emailData, callback
    else if config.emailDirectory
      log 'Not yet implemented.'
      process.exit(1)

  write: (config, message) ->
    if config.wpUrl and config.wpUsername and config.wpPassword
      (new Wordpress).write config, message
    else
      log 'write not doing anything'

  update: (config) ->
    @read config, (email) =>
      message = new Message(email)
      @write(config, message)


module.exports = Prism
