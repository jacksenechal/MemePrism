{ log, p } = require 'lightsaber'
rest = require 'restler'

class Wordpress
  constructor: (@config)->

  writeMessage: (email, callback) ->
    postData =
      type: 'post'
      status: 'draft'
      title: email.subject
      content_raw: email.text
      date: email.date.toISOString()

    request = rest.post("#{@config.wpUrl}/wp-json/posts",
      username: @config.wpUsername, password: @config.wpPassword,
      data: postData
    )

    request.on 'complete', callback if callback?

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
