{ log, p } = require 'lightsaber'
fs = require 'fs'
MailParser = require("mailparser").MailParser

class EmailParser
  constructor: (@callback)->

  readFiles: (directoryName)->
    files = fs.readdirSync(directoryName)
    files.forEach (file)=>
      filePath = directoryName+'/'+file
      if fs.lstatSync(filePath).isDirectory()
        @readFiles filePath
      else
        @readFile filePath

  readFile: (filename)->
    parser = new MailParser
    parser.on 'end', @callback
    fs.createReadStream(filename).pipe(parser)

  read: (emailData)->
    parser = new MailParser
    parser.on 'end', @callback
    parser.write emailData
    parser.end()

module.exports = EmailParser
