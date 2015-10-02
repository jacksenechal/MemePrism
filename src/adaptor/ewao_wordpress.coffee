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
escapeStringRegexp = require 'escape-string-regexp'

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
    # collect promises for downloaded media
    mediaLoaded = []

    # get the article's featured image
    mediaLoaded.push @writeMedia url: article.image

    # general article cleanup
    article.content = @_sanitizeUrls article.content

    # capture and save base64 encoded images as media files
    mediaRegex = /src="data:([^;]*);base64,([^"]*?)"/gi
    matches = article.content.match(mediaRegex) or []
    for match in matches
      extracts = mediaRegex.exec match
      type = extracts[1]
      data = extracts[2]
      filename = @_makeFilename {data, type}
      article.content = article.content.replace mediaRegex, "src=\"#{filename}\""
      mediaLoaded.push @writeMedia {data, type, filename, origUrl: filename}

    # capture and save linked images as media files
    mediaRegex = /<img [^>]*src="([^"]*?)"[^>]*>/gi
    matches = article.content.match(mediaRegex) or []
    for match in matches
      debug 'match', match
      extracts = mediaRegex.exec match
      debug 'extracts', extracts
      if extracts?
        url = extracts[1]
        debug 'url', url
        mediaLoaded.push @writeMedia {url}

    # once all media has been loaded
    Promise.all mediaLoaded
      .then (media) => # replace media urls in article
        for file in media
          article.content = article.content.replace new RegExp(escapeStringRegexp file.origUrl), file.url
        media
      .then (media) => # write article to wordpress
        featuredImage = media[0]
        data =
          post_type:    'post'
          post_status:  'publish'
          post_date:    article.created_on
          post_content: article.content
          post_title:   article.title
          post_author:  1 #@authors[article.author]
          post_excerpt: article.description
          post_thumbnail: featuredImage.id
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

  writeMedia: ({url, data, type, filename, origUrl}) ->
    new Promise (resolve, reject) =>
      unless url? or (data? and type? and filename?)
        reject "Insufficient arguments. Need either URL, or data, type, and filename"

      if url?
        downloaded = @_getRemoteMedia url
          .then @writeMedia.bind @
        resolve downloaded

      file =
        name: filename
        type: type
        bits: new Buffer data, 'base64'
        overwrite: false

      log "writing media file: #{file.name}, #{file.type}"
      @wordpress.uploadFile file, (error, result) ->
        if error
          console.error red error, "\nfilename: ", result.file
          reject error
        else
          result.origUrl = origUrl
          debug "created media file: #{JSON.stringify result}"
          resolve result

  _getRemoteMedia: (url) ->
    url = @_sanitizeUrls url
    log "downloading media file: #{url}"
    request uri: url, resolveWithFullResponse: true, encoding: null
      .then (response) =>
        type = response.headers['content-type'] or throw new Error "Unable to determine content type for #{url}"
        data = response.body
        filename = @_makeFilename {data, type}
        {data, type, filename, origUrl: url}

  _makeFilename: ({data, type}) ->
    ext = mime.extension(type) or throw new Error "Unable to determine extension for #{type}"
    "#{md5 data}.#{ext}"

  _sanitizeUrls: (body) ->
    body.replace /(https?:\/)([^\/])/gi, '$1/$2'

module.exports = Wordpress
