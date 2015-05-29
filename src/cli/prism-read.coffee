Prism = require '../core/prism'
config = require 'commander'

config
  .parse process.argv

(new Prism).read config
