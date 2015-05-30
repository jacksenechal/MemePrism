{ log, p } = require 'lightsaber'
Prism = require '../core/prism'
config = require 'commander'

class CLI
  SUBCOMMANDS = {}

  SUBCOMMANDS.read = [
    ['option', '-f, --email-file <Email File>', 'File which contains a raw mime-formatted email to parse']
    ['option', '-d, --email-directory <Directory>', 'Directory which contains raw email files and subdirectories containing email files.']
  ]

  SUBCOMMANDS.write = [
    ['option', '-u, --wp-url <Wordpress REST API URL>']
    ['option', '-n, --wp-username <Wordpress username>']
    ['option', '-p, --wp-password <Wordpress password>']
  ]

  SUBCOMMANDS.update = SUBCOMMANDS.read[...]
  SUBCOMMANDS.update.push SUBCOMMANDS.write...

  exec: (subcommand) ->
    options = SUBCOMMANDS[subcommand]
    for option in options
      [func, args...] = option
      config = config[func](args...)

    config.parse process.argv
    prism = new Prism
    prism[subcommand](config)

module.exports = new CLI
