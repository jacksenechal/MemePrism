{ json, log, p, pjson } = require 'lightsaber'
_ = require 'lodash'
Promise = require "bluebird"
rest = require 'restler'
escape = require 'escape-html'
debug = require('debug')('wordpress')

class Wordpress

  constructor: (@config) ->
#    @postToThread = {}
#    @threadToPost = {}
    @threads = {}

  debug: (args...) ->
    debug args...

  buildThreadMapping: (pageNum) ->
    pageNum ?= 1
    @listPageOfPosts(pageNum).then (posts) =>
#      return if _.isEmpty posts
      debug posts
      for post in posts
        for meta in post.post_meta
          if meta.key is 'threadId'
            threadId = meta.value
            if @threads[threadId]?
              console.error("Duplicate post for #{threadId}: original: #{@threads[threadId]} duplicate: #{postId}")
            else
              debug(threadId, postId)
              @threads[threadId] = postId
            break
      @buildThreadMapping(pageNum+1)

  listPageOfPosts: (pageNumber) ->
    postsPerPage = 10
    debug "Fetching thread IDs: page #{pageNumber}"
    new Promise (resolve, reject) =>
      url = "#{@config.wpUrl}/wp-json/posts?" +
          "context=edit&" +
          "filter[post_status]=any&" +
          "filter[posts_per_page]=#{postsPerPage}" +
          "filter[offset]=#{(pageNumber-1)*postsPerPage}"
      request = rest.get url, username: @config.wpUsername, password: @config.wpPassword
      request.on 'complete', resolve
#      request.on 'success', resolve
#      request.on 'fail', reject

  # massageThreadMaps: ->
  #   threadToPosts = {}
  #   for post, thread of @postToThread
  #     threadToPosts[thread] ?= []
  #     threadToPosts[thread].push post
  #
  #   errors = _.pick threadToPosts, (posts, thread) -> posts.length > 1
  #   unless _.isEmpty errors
  #     console.error "Fatal Error: Multiple wordpress posts for the following thread IDs:"
  #     console.error "Please delete these posts and try again"
  #     console.error pjson errors
  #     process.exit 1
  #
  #   for thread, post of threadToPosts
  #     @threadToPost[thread] = post[0]
  #
  #   @debug pjson @postToThread
  #   @debug "Thread to post mapping:"
  #   @debug pjson @threadToPost

  writeThread: (messages) ->
    messages.sort (a, b) -> a.date - b.date
    originalMessage = messages[0]
    postContent = @formatPost messages
    if postContent
      options =
        date: originalMessage.date
        title: originalMessage.subject or throw new Error "No subject for message #{json originalMessage}"
        threadId: originalMessage.threadId
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
      @cleanText message
      message.fromName = message.from?[0]?.name or message.from?[0]?.address
      unless message.fromName
        console.error "No name found :: message.from is #{json message.from} :: message ID is #{message.id}"
      unless message.date
        console.error "No date found :: message ID is #{message.id}"

  cleanText: (message) ->
    cleanText = message.text
    cleanText = cleanText.replace /<mailto:.+?>/g, ''
    cleanText = cleanText.replace /--\s*You received this message because you are subscribed to the Google Group(.|\n)*/, ''
    cleanText = cleanText.replace /\n\s*>.*?$/gm, ''
    cleanText = escape cleanText
    message.cleanText = cleanText

  createOrUpdateMessage: (postContent, options={}) ->
    data =
      type: 'post'
      status: 'publish'
      title: options.title
      content_raw: postContent
      date: options.date?.toISOString()
      post_meta: [{key: 'threadId', value: options.threadId}, {key: '_wpac_is_members_only', value: 'true'}]

    postId = @threads[options.threadId]
    if postId?
      @debug "Updating: #{postId} :: #{data.date} :: #{data.title}"
      request = rest.put "#{@config.wpUrl}/wp-json/posts/#{postId}",
        username: @config.wpUsername, password: @config.wpPassword,
        data: data
    else
      @debug "Creating: #{data.date} :: #{data.title}"
      request = rest.post "#{@config.wpUrl}/wp-json/posts",
        username: @config.wpUsername, password: @config.wpPassword,
        data: data

    new Promise (resolve, reject) ->
      request.on 'success', resolve
      request.on 'fail', reject

module.exports = Wordpress
