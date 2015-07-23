{ json, log, p, pjson } = require 'lightsaber'
_ = require 'lodash'
escapeHtml = require 'escape-html'
debug = require('debug')('wordpress')

class WordpressPost

  constructor: (@messages) ->
    @messages.sort (a, b) -> a.date - b.date
    originalMessage = @messages[0]
    @date = originalMessage.date
    @title = originalMessage.subject or throw new Error "No subject for message #{pjson originalMessage}"
    @threadId = originalMessage.threadId or throw new Error "No thread ID for #{pjson originalMessage}"

  massage: ->
    sections = for message in @messages
      @cleanMessage message
      if message.id
        """
          <section>
            <h3>#{message.fromName}</h3>
            <p>
              <i>#{message.date}</i>
            </p>
            <div>
              #{message.cleanText}
            </div>
          </section>
        """
    @content = _.compact(sections).join "\n\n<hr />\n\n"

  cleanMessage: (message) ->
    throw pjson(message) if message.id?  # make sure there is no message.id already
    if message.id = message.headers?['message-id']
      message.cleanText = @cleanHtml message.text
      message.fromName = message.from?[0]?.name or message.from?[0]?.address
      unless message.fromName
        console.error "No name found :: message.from is #{json message.from} :: message ID is #{message.id}"
      unless message.date
        console.error "No date found :: message ID is #{message.id}"

  cleanHtml: (text) -> escapeHtml text

  cleanText: (text) ->
    text
      .replace /<mailto:.+?>/g, '<(removed)>'
      .replace /\b[\w.+-]+@[a-z0-9-.]+\b/ig, '<(removed)>'
      .replace /--\s*You received this message because you are subscribed to the Google Group(.|\n)*/, ''
      .replace /\n\s*>.*?$/gm, ''   # lines beginning with >

module.exports = WordpressPost
