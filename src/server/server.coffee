#require 'newrelic'
express = require "express"
lightsaber = require "lightsaber"
{ json, log, p } = lightsaber

app = express()

# favicon requests > /dev/null
app.get "/favicon.ico", ->

app.get "/", (req, res) ->
  res.send json hello: 'world'

port = process.env.PORT or 7777
server = app.listen port, -> log "Started on port #{port}"

