fs = require 'fs'
{ log, p } = require 'lightsaber'
Promise = require("bluebird")
Wordpress = require '../adaptor/wordpress'
EmailParser = require '../adaptor/email_parser'
Message = require '../models/message'
Thread = require '../models/thread'

class Prism
  read: (config) ->
    emailParser = new EmailParser
    if config.emailFile
      emailParser.readFile config.emailFile
    else if config.emailDirectory
      emailParser.readFiles config.emailDirectory
    else
      console.error 'No known source to read from'
      process.exit 1


  write: (config, emails, callback) ->
    if config.wpUrl and config.wpUsername and config.wpPassword
      wordpress = new Wordpress config
      wordpress.writeThread emails, callback
    else
      console.error 'No known target to write to'
      process.exit 1

  update: (config) ->
    @threads = {}

    @read(config).then (results)=>
      for email in results
        @threads[email.threadId] ?= []
        @threads[email.threadId].push email

      for thread, emails of @threads
        @write config, emails, (data) ->
          log "Wrote to wordpress: ID #{data.ID} GUID #{data.guid} :: #{data.title}"

module.exports = Prism
