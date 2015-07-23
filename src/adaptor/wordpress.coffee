{ json, log, p, pjson } = require 'lightsaber'
_ = require 'lodash'
Promise = require 'bluebird'
wporg = require 'wporg'
rest = require 'restler'
escapeHtml = require 'escape-html'
debug = require('debug')('wordpress')

WordpressPost = require './wordpress_post'

class Wordpress
  MAX_EXPECTED_WP_POSTS: 1e+6

  constructor: (@config) ->
    @wordpress = wporg.createClient
      username: @config.wpUsername
      password: @config.wpPassword
      url: "#{@config.wpUrl}/xmlrpc.php"

    @postToThread = {}
    @threadToPost = {}

  buildThreadMapping: (pageNum) ->
    filter = number: 100000
    promise = new Promise (resolve, reject) =>
      @wordpress.getPosts filter, null, (error, posts) =>
        if error
          throw error
        else
          for post in posts
            for field in post.custom_fields
              if field.key is 'threadId'
                @postToThread[post.post_id] = field.value
        resolve()
    promise

  massageThreadMaps: ->
    threadToPosts = {}
    for post, thread of @postToThread
      threadToPosts[thread] ?= []
      threadToPosts[thread].push post

    for thread, posts of threadToPosts
      @threadToPost[thread] = posts.shift()
      if posts.length > 0
        for extra_post_id in posts
          do (extra_post_id) =>
            @wordpress.deletePost extra_post_id, (error, posts) =>
              throw error if error
              debug "Deleted extra post ##{extra_post_id}"

    debug "Thread to post mapping:"
    debug pjson @threadToPost

  writeThread: (messages) ->
    post = new WordpressPost messages
    @createOrUpdatePost post

  createOrUpdatePost: (post) ->
    postId = @threadToPost[post.threadId]

    data =
      type: 'post'
      status: 'private'  # 'publish'
      title: post.title
      content_raw: post.content
      date: post.date?.toISOString()

    if postId?
      postUrl = "#{@config.wpUrl}/wp-json/posts/#{postId}"
      debug "Updating: #{postId} :: #{data.date} :: #{data.title}"
      request = rest.put postUrl,
        username: @config.wpUsername, password: @config.wpPassword,
        data: data
    else

      debug "Creating: #{data.date} :: #{data.title}"
      data.post_meta = [{key: 'threadId', value: post.threadId}]
      request = rest.post "#{@config.wpUrl}/wp-json/posts",
        username: @config.wpUsername, password: @config.wpPassword,
        data: data

    new Promise (resolve, reject) ->
      request.on 'complete', resolve

module.exports = Wordpress
