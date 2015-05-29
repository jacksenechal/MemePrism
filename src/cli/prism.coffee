program = require 'commander'

program
  .command 'read', 'read messages'
  .command 'write', 'write messages'
  .command 'update', 'read messages, then write'
  .parse process.argv
