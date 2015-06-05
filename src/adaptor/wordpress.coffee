{ log, p } = require 'lightsaber'
Promise = require "bluebird"
rest = require 'restler'
api = require 'wordpress'

class Wordpress
  constructor: (@config)->

  writeThread: (emails, callback) ->
    emails.sort (a, b) ->
      b.date - a.date
    [post, comments...] = emails
    @writeMessage(post, callback).then (data) =>
      postID = data.ID
      for comment in comments
        @writeComment postID, comment, callback
#    .catch (e) -> console.error e

  writeMessage: (email, callback) ->
    data =
      type: 'post'
      status: 'publish'  #'draft'
      title: email.subject
      content_raw: email.text
      date: email.date.toISOString()

    request = rest.post("#{@config.wpUrl}/wp-json/posts",
      username: @config.wpUsername, password: @config.wpPassword,
      data: data
    )

#    request.on 'complete', callback

    new Promise (resolve, reject) ->
      request.on 'complete', (data) ->
        callback(data) if callback?
        resolve(data)

  writeComment: (postId, message, callback) ->
    data =
      type: 'comment'
      status: 'approved'
      content: message.text
      date: message.date.toISOString()
      post_id: postId

#    request = rest.post("#{@config.wpUrl}/wp-json/posts/#{postId}/comments",
#      username: @config.wpUsername, password: @config.wpPassword,
#      data: data
#    )

    if @config.wpUrl.search(/// ^https:// ///) is -1
      console.error "\nWARNING: Depending on your host, Wordpress URL may need to start with https://\n"
    client = api.createClient
      url: @config.wpUrl
      username: @config.wpUsername
      password: @config.wpPassword

    p 555, data
    client.newComment data, -> log 111, arguments..., 222

    request.on 'complete', callback if callback?

module.exports = Wordpress






















