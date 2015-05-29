Prism = require '../core/prism'
config = require 'commander'

config
  .option '-u, --wp-url <Wordpress REST API URL>'
  .option '-n, --wp-username <Wordpress username>'
  .option '-p, --wp-password <Wordpress password>'
  .parse process.argv

(new Prism).write config
