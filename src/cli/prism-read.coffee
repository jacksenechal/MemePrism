#(require 'dotenv').load()  # load vars in .env file into process.env
#lightsaber = require 'lightsaber'
#{ log, p } = require 'lightsaber'
Prism = require '../core/prism'
config = require 'commander'

config
  .option '-g, --google-group <Google Group name>', 'Google Group name to import/update'
  .parse process.argv

(new Prism).read config
