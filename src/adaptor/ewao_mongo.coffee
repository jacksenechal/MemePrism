{ log, p } = require 'lightsaber'
Promise = require 'bluebird'
mongo = require 'mongodb-bluebird'
_ = require 'lodash'

DEBUG = 1

class EwaoMongo
  constructor: (@config) ->

  readArticles: ->
    mongo.connect "mongodb://localhost:#{@config.mongoPort}/#{@config.mongoDb}"
      .then (db) ->
        log 'mongo connected'
        collection = db.collection 'articles'
        collection.find({}).then (articles) ->
          log "found #{articles.length} articles"
          db.close().then ->
            log 'mongo disconnected'
          articles
      .catch (err) ->
        log 'error', err

module.exports = EwaoMongo
