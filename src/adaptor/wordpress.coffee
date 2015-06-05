{ log, p } = require 'lightsaber'
Promise = require "bluebird"
rest = require 'restler'
escape = require 'escape-html'

class Wordpress
  threadMapping: {}

  constructor: (@config)->

  buildThreadMapping: ->
    @listAllPosts().then (posts)=>
      for post in posts
        for meta in post.post_meta
          if meta.key == 'threadId'
            @threadMapping[meta.value] = post.ID
            break

  listAllPosts: ->
    new Promise (resolve, reject)=>
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

  createOrUpdateMessage: (postContent, options) ->
    postId = @threadMapping[options.threadId]

    data =
      type: 'post'
      status: 'draft'
      title: options.title
      content_raw: postContent
      date: options.date.toISOString()

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
