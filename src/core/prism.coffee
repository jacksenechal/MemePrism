fs = require 'fs'
{ log, p } = require 'lightsaber'
Wordpress = require '../adaptor/wordpress'
EmailParser = require '../adaptor/email_parser'
Message = require '../models/message'

class Prism
  read: (config, callback) ->
    emailParser = new EmailParser(callback)
    if config.emailFile
      emailParser.readFile(config.emailFile)
    else if config.emailDirectory
      emailParser.readFiles(config.emailDirectory)
    else
      console.error 'No known source to read from'
      process.exit 1

  write: (config, message, callback) ->
    if config.wpUrl and config.wpUsername and config.wpPassword
      (new Wordpress).write config, message, callback
    else
      console.error 'Proper credentials not provided.'
      process.exit 1

  update: (config) ->
    @read config, (email)=>
      message = new Message(email)
      @write config, message, (data)->
        log "Wrote to wordpress: ID #{data?.ID} GUID #{data?.guid} :: #{data?.title}"


module.exports = Prism
