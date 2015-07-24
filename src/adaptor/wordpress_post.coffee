{ json, log, p, pjson } = require 'lightsaber'
_ = require 'lodash'
debug = require('debug')('wordpress')

class WordpressPost

  constructor: (@messages, options) ->
    @wpUrl = options.wpUrl or throw new Error "wpUrl required for post"
    @messages.sort (a, b) -> a.date - b.date
    originalMessage = @messages[0]
    @date = originalMessage.date
    @title = originalMessage.subject or throw new Error "No subject for message #{pjson originalMessage}"
    @threadId = originalMessage.threadId or throw new Error "No thread ID for #{pjson originalMessage}"
    @content = @html()

  html: ->
    sections = for message in @messages
      tokens = message.cleanText.split(/ +/)
      leadText = tokens[0...10].join ' '  # for WP plugin to index
      """
        <section>
          <h3>#{message.fromName}</h3>
          <p>
            <i>#{message.date}</i>
          </p>
          <div>
            <h5 style="display:none">#{leadText}</h5>
            #{message.cleanText}
          </div>
        </section>
      """
    sections.join "\n\n<hr />\n\n"

  info: ->
    "#{@wpUrl}/?p=#{@id} :: #{@title} :: #{@date}"

module.exports = WordpressPost
