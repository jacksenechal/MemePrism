{ json, log, p, pjson } = require 'lightsaber'
_ = require 'lodash'
Promise = require 'bluebird'
wporg = require 'wporg'
debug = require('debug')('wordpress')
chalk = require 'chalk'

WordpressPost = require './wordpress_post'

class Wordpress
  red = chalk.bold.red
  MAX_EXPECTED_WP_POSTS = 1e+6

  constructor: (@config) ->
    @wordpress = wporg.createClient
      username: @config.wpUsername
      password: @config.wpPassword
      url: "#{@config.wpUrl}/xmlrpc.php"

    @postToThread = {}
    @threadToPost = {}

  buildThreadMapping: (pageNum) ->
    new Promise (resolve, reject) =>
      filter = number: MAX_EXPECTED_WP_POSTS
      @wordpress.getPosts filter, null, (error, posts) =>
        if error
          throw error
        else
          for post in posts
            for field in post.custom_fields
              if field.key is 'threadId'
                @postToThread[post.post_id] = field.value
        resolve()

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
    post = new WordpressPost messages, wpUrl: @config.wpUrl
    post.id = @threadToPost[post.threadId]

    data =
      post_type:    'post'
      post_status:  'publish'
      post_date:    post.date
      post_content: post.content
      post_title:   post.title
      terms_names:
        category: ['Discussion Thread']
        # post_tag: ['Tag One','Tag Two', 'Tag Three']

    if post.id?
      @wordpress.editPost post.id, data, (error, result) ->
        if error
          console.error red error
        else
          debug "Updated: #{post.info()}"
    else
      data.custom_fields = [
        {key: 'threadId', value: post.threadId}
        {key: '_wpac_is_members_only', value: 'true'}
      ]
      @wordpress.newPost data, (error, postId) ->
        if error
          console.error red error
        else
          post.id = postId
          debug "Created: #{post.info()}"

module.exports = Wordpress
