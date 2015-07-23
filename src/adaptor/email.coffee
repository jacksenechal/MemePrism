{ log, p } = require 'lightsaber'
escapeHtml = require 'escape-html'

class Email
  @wrap: (email, options) ->
    @cleanMessage email
    @setThreadId email, options
    email

  @cleanMessage: (email) ->
    throw pjson(message) if email.id?  # make sure there is no @email.id already
    email.id = email.headers?['message-id']
    email.valid = email.id?
    email.cleanText = escapeHtml @cleanText email.text
    email.fromName = email.from?[0]?.name or email.from?[0]?.address
    unless email.fromName
      console.error "No name found :: message.from is #{json email.from} :: message ID is #{email.id}"
    unless email.date
      console.error "No date found :: message ID is #{email.id}"

  @setThreadId: (email, options) ->
    filename = options.filename or throw new Error "No filename given for email: #{pjson email}"
    filename = filename[0...-1] if filename.match(/// /$ ///)  # trim trailing slash
    threadDirectory = filename.split('/')[-2..-2][0]           # last directory name
    email.threadId = threadDirectory

  @cleanText: (text) ->
    text
      .replace /<mailto:.+?>/g, '<(removed)>'
      .replace /\b[\w.+-]+@[a-z0-9-.]+\b/ig, '<(removed)>'
      .replace /--\s*You received this message because you are subscribed to the Google Group(.|\n)*/, ''
      .replace /\n\s*>.*?$/gm, ''   # lines beginning with >

module.exports = Email
