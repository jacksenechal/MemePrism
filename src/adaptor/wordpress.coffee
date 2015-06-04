{ log, p } = require 'lightsaber'
rest = require 'restler'

class Wordpress
  write: (config, message, callback) ->
    postData =
      type: 'post'
      status: 'draft'
      title: message.get 'subject'
      content_raw: message.get 'text'
      date: message.get('date').toISOString()

    request = rest.post("#{config.wpUrl}/wp-json/posts",
      username: config.wpUsername, password: config.wpPassword,
      data: postData
    )

    request.on 'complete', callback if callback?

module.exports = Wordpress
