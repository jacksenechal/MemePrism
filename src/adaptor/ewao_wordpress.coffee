{ json, log, p, pjson } = require 'lightsaber'
_ = require 'lodash'
Promise = require 'bluebird'
wporg = require 'wporg'
debug = require('debug')('wordpress')
chalk = require 'chalk'
md5 = require 'js-md5'
request = require 'request-promise'
mime = require 'mime'
fs = require 'fs'
https = require 'https'

# WordpressPost = require './wordpress_post'

class Wordpress
  red = chalk.bold.red
  MAX_EXPECTED_WP_POSTS = 1e+6

  constructor: (@config) ->
    @wordpress = wporg.createClient
      username: @config.wpUsername
      password: @config.wpPassword
      url: "#{@config.wpUrl}/xmlrpc.php"

    @authors = {}

    @categories =
      "5xf4F6wNdCvn99kqj": '1' # "News"
      "zEG4a7tHmychqAqH7": '2' # "Inspiration"
      "kFyCNMFZ4gyf4sM9T": '3' # "Health & Wellness"
      "uwj6gP5w3tcDCHRE4": '4' # "Flower of Life"
      "8tpkEKhLLPoiWdFLz": '5' # "Universe Explorers"

  writeArticle: (article) ->
    # kick out base64 encoded images...
    content = article.content.replace /src=\"data:image[^\\]*\"/, 'src="XXX"'
    # capture and save them as media files
    # mediaRegex = /src=\"data:(image\/[^;]*);base64,([^"]*)\"/gi
    # matches = article.content.match mediaRegex
    # for match in matches
    #   [x, type, data] = mediaRegex.exec match
    #   @writeMedia data, type

    @writeMedia url: article.image
      .then (imageId) =>
        imageUrl = "/xxx/#{imageId}"

        data =
          post_type:    'post'
          post_status:  'publish'
          post_date:    article.created_on
          post_content: content
          post_title:   article.title
          post_author:  1 #@authors[article.author]
          post_excerpt: article.description
          # post_format: 'image'
          # post_thumbnail: imageUrl
          post_status: if article.draft then 'draft' else 'publish'
          post_name: article.slug
          # terms_names:
          #   category: [@categories[article.category]]
            # post_tag: ['Tag One','Tag Two', 'Tag Three']

        log "writing article: #{article.title}"
        # log data

        @wordpress.newPost data, (error, id) ->
          if error
            console.error red error, "\narticle: ", article.title
          else
            debug "created article: #{id}"

  writeMedia: ({url, data, type, filename}) ->
    new Promise (resolve, reject) =>
      unless url? or (data? and type? and filename?)
        reject "Insufficient arguments. Need either URL, or data, type, and filename"

      if url?
        downloaded = @_getRemoteMedia url
          .then @writeMedia.bind @
        resolve downloaded

      media =
        name: filename
        type: type
        bits: new Buffer data, 'base64'
        overwrite: false

      log "writing media: #{media.name}, #{media.type}"
      @wordpress.uploadFile media, (error, id) ->
        if error
          console.error red error, "\nfilename: ", media.name
          reject error
        else
          debug "created media: #{id}"
          resolve id

  _getRemoteMedia: (url) ->
    url = @_makeSaneUrl url
    log "downloading media: #{url}"
    request uri: url, resolveWithFullResponse: true, encoding: null
      .then (response) ->
        type = response.headers['content-type'] or throw new Error "Unable to determine content type for #{url}"
        ext = mime.extension(type) or throw new Error "Unable to determine extension for #{type}"
        data = response.body
        filename = "#{md5 data}.#{ext}"
        fs.writeFile "tmp/#{filename}", data
        {data, type, filename}

  _makeSaneUrl: (url) ->
    url.replace /(https?:\/)([^\/])/, '$1/$2'

module.exports = Wordpress
