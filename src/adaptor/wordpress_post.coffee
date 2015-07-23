{ json, log, p, pjson } = require 'lightsaber'
_ = require 'lodash'
debug = require('debug')('wordpress')

class WordpressPost

  constructor: (@messages) ->
    @messages.sort (a, b) -> a.date - b.date
    originalMessage = @messages[0]
    @date = originalMessage.date
    @title = originalMessage.subject or throw new Error "No subject for message #{pjson originalMessage}"
    @threadId = originalMessage.threadId or throw new Error "No thread ID for #{pjson originalMessage}"
    @content = @html()

  html: ->
    sections = for message in @messages
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
    sections.join "\n\n<hr />\n\n"

module.exports = WordpressPost
