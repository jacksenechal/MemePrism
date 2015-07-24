fs = require 'fs'
{ log, p, pjson } = require 'lightsaber'
Promise = require 'bluebird'
_ = require 'lodash'
Wordpress = require '../adaptor/wordpress'
EmailParser = require '../adaptor/email_parser'

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


  write: (config, threads) ->
    if config.wpUrl and config.wpUsername and config.wpPassword
      wordpress = new Wordpress config
      wordpress.buildThreadMapping().then =>
        wordpress.massageThreadMaps()
        for threadId, thread of threads
          wordpress.writeThread thread
    else
      console.error 'No known target to write to: requires Wordpress URL, username, and password.'
      process.exit 1

  update: (config) ->
    threads = {}

    @read(config).then (results) =>
      results = _.flatten results # flatten array of arrays if recursing subdirectories
      for email in results
        threads[email.threadId] ?= []
        threads[email.threadId].push email

      @write config, threads

module.exports = Prism
