{ log, p } = require 'lightsaber'
rest = require 'restler'

class Wordpress

  write: (config) ->
    url = config.wpUrl
    username = config.wpUsername
    password = config.wpPassword

    # bin/prism-write -u http://104.236.184.200 -n name -p pass
    # http://wp-api.org/guides/authentication.html
    rest.get("#{url}/wp-json/posts").on 'complete', (data) ->
      #console.log(data[0].sounds[0].sound[0].message); // auto convert to object
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
