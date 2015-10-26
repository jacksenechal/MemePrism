Promise = require 'bluebird'
EwaoWordpress = require '../adaptor/ewao_wordpress'
EwaoMongo = require '../adaptor/ewao_mongo'
_ = require 'lodash'
{ log, p, pjson } = require 'lightsaber'
{ exec, error } = require 'shelljs'

class Prism
  read: (config) ->
    remoteCommand = """
      rm -rf /tmp/prism-mongo-dump \
      && mkdir -p /tmp/prism-mongo-dump \
      && cd /tmp/prism-mongo-dump \
      && mongodump --db #{config.serverMongoDb} --port #{config.serverMongoPort}
    """
    res = exec "ssh #{config.serverUser}@#{config.serverHost} '#{remoteCommand}'"
    if error()? then process.exit 1

    res = exec "rsync -avz #{config.serverUser}@#{config.serverHost}:/tmp/prism-mongo-dump /tmp/"
    if error()? then process.exit 1

    res = exec "mongorestore --drop --host 127.0.0.1 --port #{config.mongoPort} --db #{config.mongoDb} --dir /tmp/prism-mongo-dump/dump/#{config.mongoDb}"
    if error()? then process.exit 1


  write: (config) ->
    postCount = 0
    delay = 0
    if config.wpUrl and config.wpUsername and config.wpPassword and config.mongoPort and config.mongoDb
      ewao = new EwaoMongo config
      wordpress = new EwaoWordpress config
      ewao.readArticles()
        .then (articles) =>
          for article, i in articles
            if i >= config.limit then break
            wordpress.writeArticle article

    else
      console.error 'Insufficient options: requires Wordpress URL, username, and password, as well as MongoDB port and DB name.'
      process.exit 1

  migrate: (config) ->
    threads = {}

    @read(config).then (results) =>
      @write config

module.exports = Prism
