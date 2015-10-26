{ log, p } = require 'lightsaber'
_ = require 'lodash'
Prism = require '../core/prism'
config = require 'commander'

class CLI
  SUBCOMMANDS = {}

  SUBCOMMANDS.read = [
    ['option', '--mongo-port <Port Number>', 'Local mongodb port']
    ['option', '--mongo-db <DB Name>', 'Local mongodb database name']
    ['option', '--server-host <Host>', 'IP/domain of remote server']
    ['option', '--server-user <URL>', 'SSH username on remote server']
    ['option', '--server-mongo-port <Port Number>', 'Remote mongodb port']
    ['option', '--server-mongo-db <DB Name>', 'Remote mongodb database name']
  ]

  SUBCOMMANDS.write = [
    ['option', '--mongo-port <Port Number>', 'Local mongodb port']
    ['option', '--mongo-db <DB Name>', 'Local mongodb database name']
    ['option', '--wp-url <Wordpress REST API URL>']
    ['option', '--wp-username <Wordpress username>']
    ['option', '--wp-password <Wordpress password>']
    ['option', '--limit <max articles to write>']
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
