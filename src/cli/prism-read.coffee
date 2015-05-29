Prism = require '../core/prism'
config = require 'commander'

config
  .option '-f, --email-file <Email File>', 'File which contains a raw mime-formatted email to parse'
  .option '-d, --email-directory <Directory>', 'Directory which contains raw email files and subdirectories containing email files.'
  .parse process.argv

(new Prism).read config
