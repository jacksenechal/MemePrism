{ json, log, p, pjson } = require 'lightsaber'
_ = require 'lodash'
Promise = require 'bluebird'
wporg = require 'wporg'
rest = require 'restler'
escapeHtml = require 'escape-html'
debugWp = require('debug')('wordpress')

class Wordpress

  constructor: (@config) ->
    @wordpress = wporg.createClient
      username: @config.wpUsername
      password: @config.wpPassword
      url: "#{@config.wpUrl}/xmlrpc.php"

    @postToThread = {}
    @threadToPost = {}

  debug: (args...) ->
    debugWp args...

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
      if posts.length > 1
        for extra_post_id in posts[1..-1]
          do (extra_post_id) =>
            @wordpress.deletePost extra_post_id, (error, posts) =>
              if error
                throw error
              else
                @debug "Deleted extra post ##{extra_post_id}"

    for thread, post of threadToPosts
      @threadToPost[thread] = post[0]

    @debug "Thread to post mapping:"
    @debug pjson @threadToPost

  writeThread: (messages) ->
    messages.sort (a, b) -> a.date - b.date
    originalMessage = messages[0]
    postContent = @formatPost messages
    if postContent
      options =
        date: originalMessage.date
        title: originalMessage.subject or throw new Error "No subject for message #{json originalMessage}"
        threadId: originalMessage.threadId ? throw new Error "No thread ID for #{json originalMessage}"
      @createOrUpdateMessage postContent, options
    else
      Promise.resolve()

  formatPost: (messages) ->
    contents = for message in messages
      @cleanMessage message
      if message.id
        """
          <section>
            <h3>#{message.fromName}</h3>
            <p>
              <i>#{message.date}</i>
            </p>
            <div>
              #{message.cleanText}
            </div>
          </section>
        """
    _.compact(contents).join "\n\n<hr />\n\n"

  cleanMessage: (message) ->
    throw pjson(message) if message.id?  # make sure there is no message.id already
    if message.id = message.headers?['message-id']
      message.cleanText = @cleanHtml message.text
      message.fromName = message.from?[0]?.name or message.from?[0]?.address
      unless message.fromName
        console.error "No name found :: message.from is #{json message.from} :: message ID is #{message.id}"
      unless message.date
        console.error "No date found :: message ID is #{message.id}"

  cleanHtml: (text) -> escapeHtml text

  cleanText: (text) ->
    text
      .replace /<mailto:.+?>/g, '<(removed)>'
      .replace /\b[\w.+-]+@[a-z0-9-.]+\b/ig, '<(removed)>'
      .replace /--\s*You received this message because you are subscribed to the Google Group(.|\n)*/, ''
      .replace /\n\s*>.*?$/gm, ''   # lines beginning with >

  createOrUpdateMessage: (postContent, options) ->
    postId = @threadToPost[options.threadId]

    data =
      type: 'post'
      status: 'private'  # 'publish'
      title: options.title
      content_raw: postContent
      date: options.date?.toISOString()

    if postId?
      postUrl = "#{@config.wpUrl}/wp-json/posts/#{postId}"
      @debug "Updating: #{postId} :: #{data.date} :: #{data.title}"
      request = rest.put postUrl,
        username: @config.wpUsername, password: @config.wpPassword,
        data: data
    else

      @debug "Creating: #{data.date} :: #{data.title}"
      data.post_meta = [{key: 'threadId', value: options.threadId}]
      request = rest.post "#{@config.wpUrl}/wp-json/posts",
        username: @config.wpUsername, password: @config.wpPassword,
        data: data

    new Promise (resolve, reject) ->
      request.on 'complete', resolve

module.exports = Wordpress
