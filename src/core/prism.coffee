{ log, p } = require 'lightsaber'
Wordpress = require '../adaptor/wordpress'
fs = require 'fs'
Email = require '../adaptor/email'
Message = require '../models/message'

class Prism
  read: (config, callback) ->
    if config.emailFile
      emailData = fs.readFileSync config.emailFile, encoding: 'utf8'
      (new Email).read emailData, callback
    else if config.emailDirectory
      console.error 'Not yet implemented.'
      process.exit 1
    else
      console.error 'No known source to read from'
      process.exit 1

  write: (config, message) ->
    if config.wpUrl and config.wpUsername and config.wpPassword
      (new Wordpress).write config, message
    else
      console.error 'No known target to write to'
      process.exit 1

  update: (config) ->
    @read config, (email) =>
      message = new Message(email)
      @write(config, message)


module.exports = Prism
