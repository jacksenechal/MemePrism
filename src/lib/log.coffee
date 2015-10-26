Log = require 'log'
fs = require 'fs'
stream = fs.createWriteStream __dirname + '/../../migrate.log', { flags: 'a' }
log = new Log 'info', stream
module.exports = log
