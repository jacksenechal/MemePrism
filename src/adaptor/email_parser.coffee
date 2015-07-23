{ log, p } = require 'lightsaber'
fs = require 'fs'
path = require 'path'
Promise = require("bluebird")
MailParser = require("mailparser").MailParser

Email = require './email'

class EmailParser
  readFiles: (directoryName) ->
    files = fs.readdirSync(directoryName)
    promises = Promise.map files, (file) =>
      filePath = path.resolve directoryName, file
      if fs.lstatSync(filePath).isDirectory()
        @readFiles filePath
      else
        @readFile filePath
    , concurrency: 25

    Promise.all(promises)

  readFile: (filename) ->
    new Promise (resolve, reject) =>
      parser = new MailParser
      fs.createReadStream(filename).pipe(parser)
      parser.on 'end', (email) ->
        wrappedEmail = Email.wrap email, { filename }
        if wrappedEmail.valid
          resolve wrappedEmail
        else
          Promise.resolve()

module.exports = EmailParser
