{ log, p } = require 'lightsaber'
_ = require 'lodash'
Prism = require '../core/prism'
config = require 'commander'

class CLI
  SUBCOMMANDS = {}

  SUBCOMMANDS.read = [
    ['option', '-t, --mongo-port <Port Number>', 'Local mongodb port']
    ['option', '-d, --mongo-db-name <DB Name>', 'Local mongodb database name']
    # ['option', '-f, --email-file <Email File>', 'File which contains a raw mime-formatted email to parse']
    # ['option', '-d, --email-directory <Directory>', 'Directory which contains raw email files and subdirectories containing email files.']
  ]

  SUBCOMMANDS.write = [
    ['option', '-t, --mongo-port <Port Number>', 'Local mongodb port']
    ['option', '-d, --mongo-db-name <DB Name>', 'Local mongodb database name']
    ['option', '-u, --wp-url <Wordpress REST API URL>']
    ['option', '-n, --wp-username <Wordpress username>']
    ['option', '-p, --wp-password <Wordpress password>']
    ['option', '-l, --limit <max articles to write>']
  ]

  SUBCOMMANDS.migrate = SUBCOMMANDS.read[...]    # make a copy of SUBCOMMANDS.export
  SUBCOMMANDS.migrate.push SUBCOMMANDS.write...
  SUBCOMMANDS.migrate = _.uniq SUBCOMMANDS.migrate, (n) -> n[1]

  exec: (subcommand) ->
    options = SUBCOMMANDS[subcommand]
    for option in options
      [methodName, args...] = option
      config = config[methodName](args...)

    config.parse process.argv
    prism = new Prism
    prism[subcommand](config)

module.exports = new CLI
