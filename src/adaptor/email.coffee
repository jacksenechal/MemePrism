{ log, p } = require 'lightsaber'
fs = require 'fs'
MailParser = require("mailparser").MailParser

class Email
  constructor: ->
    @mailparser = new MailParser

  readFromFile: (filename)->
    fs.createReadStream(filename).pipe(@mailparser)

  read: (emailData, callback)->
    @mailparser.on 'end', callback
    @mailparser.write emailData
    @mailparser.end()

module.exports = Email
