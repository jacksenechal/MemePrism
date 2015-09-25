fs = require 'fs'
{ log, p, pjson } = require 'lightsaber'
Promise = require 'bluebird'
_ = require 'lodash'
EwaoWordpress = require '../adaptor/ewao_wordpress'
EwaoMongo = require '../adaptor/ewao_mongo'

class Prism
  read: (config) ->
    # emailParser = new EmailParser
    # if config.emailFile
    #   emailParser.readFile config.emailFile
    # else if config.emailDirectory
    #   emailParser.readFiles config.emailDirectory
    # else
    #   console.error 'No known source to read from'
    #   process.exit 1


  write: (config) ->
    postCount = 0
    delay = 0
    if config.wpUrl and config.wpUsername and config.wpPassword and config.mongoPort and config.mongoDbName
      ewao = new EwaoMongo config
      wordpress = new EwaoWordpress config
      ewao.readArticles()
        .then (articles) =>
          for article in articles
            wordpress.writeArticle article
            # do (article) =>
            #   setTimeout (=> wordpress.writeArticle article), delay * postCount++

    else
      console.error 'No known target to write to: requires Wordpress URL, username, and password.'
      process.exit 1

  migrate: (config) ->
    threads = {}

    @read(config).then (results) =>
      @write config

module.exports = Prism
