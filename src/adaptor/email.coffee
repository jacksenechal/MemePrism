{ log, p } = require 'lightsaber'
fs = require 'fs'
MailParser = require("mailparser").MailParser

class Email
  constructor: ->
    @mailparser = new MailParser
    @mailparser.on 'end', @parsed

  readFromFile: (filename)->
    fs.createReadStream(filename).pipe(@mailparser)

  read: (emailData)->
    @mailparser.write emailData
    @mailparser.end()

  parsed: (email)->
    debugger
    # log email

module.exports = Email
