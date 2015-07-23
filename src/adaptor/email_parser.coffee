{ log, p } = require 'lightsaber'
fs = require 'fs'
path = require 'path'
Promise = require("bluebird")
MailParser = require("mailparser").MailParser

class EmailParser
  readFiles: (directoryName)->
    files = fs.readdirSync(directoryName)
    promises = Promise.map files, (file) =>
      filePath = path.resolve directoryName, file
      if fs.lstatSync(filePath).isDirectory()
        @readFiles filePath
      else
        @readFile filePath
    , concurrency: 25

    Promise.all(promises)

  readFile: (filename)->
    filename = filename[0...-1] if filename.match(/// /$ ///)  # trim trailing slash
    threadDirectory = filename.split('/')[-2..-2][0]  # final directory name
    new Promise (resolve, reject) =>
      parser = new MailParser
      fs.createReadStream(filename).pipe(parser)
      parser.on 'end', (email)->
        email.threadId = threadDirectory
        resolve email

#  read: (emailData)->
#    parser = new MailParser
#    parser.on 'end', @callback
#    parser.write emailData
#    parser.end()

module.exports = EmailParser
