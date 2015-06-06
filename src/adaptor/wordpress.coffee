{ json, log, p, pjson } = require 'lightsaber'
{ compact } = require 'lodash'
Promise = require "bluebird"
rest = require 'restler'
escape = require 'escape-html'

class Wordpress
  threadMapping: {}

  constructor: (@config) ->

  buildThreadMapping: ->
    @listAllPosts().then (posts) =>
      for post in posts
        for meta in post.post_meta
          if meta.key == 'threadId'
            @threadMapping[meta.value] = post.ID
            break

  listAllPosts: ->
    new Promise (resolve, reject) =>
      request = rest.get "#{@config.wpUrl}/wp-json/posts?filter[post_status]=any&context=edit",
        username: @config.wpUsername, password: @config.wpPassword
      request.on 'complete', resolve

  writeThread: (messages) ->
    messages.sort (a, b) -> a.date - b.date
    originalMessage = messages[0]
    postContent = @formatPost messages
    options =
      date: originalMessage.date
      title: originalMessage.subject
      threadId: originalMessage.threadId

    @createOrUpdateMessage postContent, options

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
              <b>#{message.cleanText}</b>
            </div>
          </section>
        """
    (compact contents).join "\n\n<hr />\n\n"

  cleanMessage: (message) ->
    throw pjson(message) if message.id?  # make sure the is no .id already
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

  createOrUpdateMessage: (postContent, options) ->
    postId = @threadMapping[options.threadId]

    data =
      type: 'post'
      status: 'publish'
      title: options.title
      content_raw: postContent
      date: options.date?.toISOString()

    if postId?
      request = rest.put "#{@config.wpUrl}/wp-json/posts/#{postId}",
        username: @config.wpUsername, password: @config.wpPassword,
        data: data
    else
      data.post_meta = [{key: 'threadId', value: options.threadId}]

      request = rest.post "#{@config.wpUrl}/wp-json/posts",
        username: @config.wpUsername, password: @config.wpPassword,
        data: data

    new Promise (resolve, reject) ->
      request.on 'complete', resolve

module.exports = Wordpress
