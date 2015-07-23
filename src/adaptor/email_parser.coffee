{ log, p } = require 'lightsaber'
fs = require 'fs'
path = require 'path'
Promise = require("bluebird")
MailParser = require("mailparser").MailParser

Email = require './email'

DEBUG = 1

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
      parser.on 'end', (email) =>
        Email.massage email, { filename }
        @debugSave email, filename
        if email.valid
          resolve email
        else
          Promise.resolve()

  debugSave: (email, filename) ->
    if DEBUG
      cb = (err) -> console.error err if err
      slug = filename.split('/')[-2..-1].join('-')
      fs.writeFile "tmp/#{slug}-ORIG.txt", email.text, cb
      fs.writeFile "tmp/#{slug}-POST.txt", email.cleanText, cb

module.exports = EmailParser
