{ log, p } = require 'lightsaber'
Promise = require "bluebird"
rest = require 'restler'
escape = require 'escape-html'

class Wordpress
  threadIdToPostId: {}

  constructor: (@config)->
    @buildThreadMapping()

  buildThreadMapping: ->
    @listAllPosts().then (posts)=>
      for post in posts
        for meta in post.post_meta
          if meta.key == 'threadId'
            @threadIdToPostId[meta.value] = post.ID
            break

  listAllPosts: ->
    request = rest.get "#{@config.wpUrl}/wp-json/posts?filter[post_status]=any&context=edit",
      username: @config.wpUsername, password: @config.wpPassword
    new Promise (resolve, reject)->
      request.on 'complete', resolve

  writeThread: (messages, callback) ->
    messages.sort (a, b) -> a.date - b.date
    originalMessage = messages[0]
    postContent = @formatPost messages
    options =
      date: originalMessage.date
      title: originalMessage.subject
      threadId: originalMessage.threadId

#    @findMessageByThreadId originalMessage.threadId
    @writeMessage postContent, options, callback


  findMessageByThreadId: (threadId) ->
    request = rest.get "#{@config.wpUrl}/wp-json/posts?filter[meta_key]=threadId&filter[meta_value]=#{threadId}",
      username: @config.wpUsername, password: @config.wpPassword
    request.on 'complete', (data)->
      for d in data
        log d.ID

  formatPost: (messages) ->
    contents = for message in messages
      @cleanMessage message
      """
        <section>
          <h3>#{message.from[0].name}</h3>
          <p>
            <i>#{message.date}</i>
          </p>
          <div>
            <b>#{message.cleanText}</b>
          </div>
        </section>
      """
    contents.join "\n<hr />\n"

  cleanMessage: (message) ->
    cleanText = message.text
    cleanText = cleanText.replace /<mailto:.+?>/g, ''
    cleanText = cleanText.replace /--\s*You received this message because you are subscribed to the Google Group(.|\n)*/g, ''
    cleanText = cleanText.replace /\n\s*>.*?$/gm, ''
    cleanText = escape cleanText
    message.cleanText = cleanText

  writeMessage: (postContent, options, callback) ->
    data =
      type: 'post'
      status: 'draft'
      title: options.title
      content_raw: postContent
      date: options.date.toISOString()
      post_meta: {key: 'threadId', value: options.threadId}

    request = rest.post "#{@config.wpUrl}/wp-json/posts",
      username: @config.wpUsername, password: @config.wpPassword,
      data: data

    new Promise (resolve, reject) ->
      request.on 'complete', (data) ->
        callback(data) if callback?
        resolve(data)

module.exports = Wordpress
