{ log, p } = require 'lightsaber'
Wordpress = require '../adaptor/wordpress'
fs = require 'fs'
Email = require '../adaptor/email'

class Prism
  read: (config) ->
    if config.emailFile
      emailData = fs.readFileSync config.emailFile, encoding: 'utf8'
      email = (new Email).read(emailData)
      # write to db

    else if config.emailDirectory
      log 'Not yet implemented.'
      process.exit(1)

  write: (config) ->
    if config.wpUrl and config.wpUsername and config.wpPassword
      (new Wordpress).write config



module.exports = Prism
