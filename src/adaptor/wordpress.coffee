{ log, p } = require 'lightsaber'
rest = require 'restler'

class Wordpress
  write: (config, message) ->
    postData =
      type: 'post'
      status: 'draft'
      title: message.get 'subject'
      content_raw: message.get 'text'
      date: message.get('date').toISOString()

    rest.post("#{config.wpUrl}/wp-json/posts",
      username: config.wpUsername, password: config.wpPassword,
      data: postData
    ).on 'complete', (data, response)->
      log data


  oldWrite: (config) ->
    if config.wpUrl.search(/// ^https:// ///) is -1
      console.error "\nWARNING: Depending on your host, Wordpress URL may need to start with https://\n"
    client = api.createClient
      url: config.wpUrl
      username: config.wpUsername
      password: config.wpPassword

    post =
      type: 'post'
      title: 'Awesome!'
      status: 'draft'
      content: 'Really.'

    client.newPost post, -> log arguments

module.exports = Wordpress
