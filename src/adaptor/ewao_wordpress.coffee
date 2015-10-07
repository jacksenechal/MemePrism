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

    @whenReady = @_getMediaLibrary()
      .then (media) => @media = media
      # .then =>
      #   console.log "media keys: ", JSON.stringify _.keys(@media), null, 2
      #   process.exit 0
      .error =>
        console.error error
        process.exit 1

  _getMediaLibrary: ->
    promise = new Promise (resolve, reject) =>
      @wordpress.getMediaLibrary null, (error, media) =>
        if error?
          console.error "Unable to load media library", error
          reject error
        else
          media = _ media
            .each (item) =>
              item.md5 = @_extractLastMd5(item.link)
              unless item.md5?
                console.error "Unable to extract md5 for item: #{item.attachment_id}, #{item.link}"
            .indexBy 'md5'
            .value()
          resolve media

  writeArticle: (article) ->
    @whenReady.then =>
      # collect promises for downloaded media
      mediaLoaded = []

      # get the article's featured image
      mediaLoaded.push @writeMedia url: article.image

      # general article cleanup
      article.content = @_sanitizeUrls article.content

      # capture and save base64 encoded images as media files
      base64MediaRegex = /src="data:([^;]*);base64,([^"]*?)"/gi
      matches = article.content.match(base64MediaRegex) or []
      for match in matches
        extracts = base64MediaRegex.exec match
        if extracts?
          type = extracts[1] or console.error "Unable to determine image type", article.title, extracts
          data = extracts[2] or console.error "Unable to extract image data", article.title, extracts
          md5sum = md5 data
          filename = @_makeFilename {md5sum, type}
          article.content = article.content.replace base64MediaRegex, "src=\"#{filename}\""
          mediaLoaded.push @writeMedia {data, type, filename, origUrl: filename, md5sum}

      # capture and save linked images as media files
      externalMediaRegex = /<img [^>]*src="(https?:[^"]*?)"[^>]*>/gi
      matches = article.content.match(externalMediaRegex) or []
      for match in matches
        debug 'match', match
        extracts = externalMediaRegex.exec match
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
            terms_names:
              category: [@categories[article.category]]
              post_tag: ['EWAO Archive']

          log "writing article: #{article.title}"
          # log data

          @wordpress.newPost data, (error, id) ->
            if error
              console.error red error, "\narticle: ", article.title
            else
              debug "created article: #{id}"

  writeMedia: ({url, data, type, filename, origUrl, md5sum}) ->
    @whenReady.then =>
      new Promise (resolve, reject) =>
        unless url? or (data? and type? and filename? and md5sum?)
          reject "Insufficient arguments. Need either URL, or all of: data, type, md5sum and filename"

        if url?
          downloaded = @_getRemoteMedia url
            .then @writeMedia.bind @
          resolve downloaded
        else if @media[md5sum]?
          log "using existing media file: #{filename}, #{@media[md5sum].link}"
          resolve
            origUrl: origUrl
            url: @media[md5sum].link
        else
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
        md5sum = md5 data
        filename = @_makeFilename {md5sum, type}
        {data, type, filename, origUrl: url, md5sum}

  _makeFilename: ({md5sum, type}) ->
    ext = mime.extension(type) or throw new Error "Unable to determine extension for #{type}"
    "#{md5sum}.#{ext}"

  _extractLastMd5: (string) ->
    hashRegex = new RegExp "\\b([a-f0-9]{32})", 'g'
    matches = hashRegex.exec string
    _.last matches

  _sanitizeUrls: (body) ->
    body.replace /(https?:\/)([^\/])/gi, '$1/$2'

module.exports = Wordpress
