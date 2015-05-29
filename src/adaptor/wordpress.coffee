{ log, p } = require 'lightsaber'
api = require 'wordpress'

class Wordpress

  write: (config) ->
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
