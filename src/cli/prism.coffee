program = require 'commander'

program
  .command 'read', 'export articles from EWAO live site'
  .command 'write', 'push articles to Wordpress'
  .command 'migrate', 'export articles, then push'
  .parse process.argv
