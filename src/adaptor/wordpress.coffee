{ log, p } = require 'lightsaber'
Promise = require "bluebird"
rest = require 'restler'

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

#  writeComment: (message, callback) ->
#    commentData =
#      type: 'comment'
#      status: 'draft'
#      title: message.get 'subject'
#      content_raw: message.get 'text'
#      date: message.get('date').toISOString()
#
#    request = rest.post("#{config.wpUrl}/wp-json/posts",
#      username: @config.wpUsername, password: @config.wpPassword,
#      data: commentData
#    )
#
#    request.on 'complete', callback if callback?

module.exports = Wordpress
