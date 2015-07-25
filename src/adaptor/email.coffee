{ json, log, p } = require 'lightsaber'
escapeHtml = require 'escape-html'

class Email
  EMAIL_PATTERN = '\\b[\\w.+-]+@[a-z0-9-.]+\\b'
  REMOVED = '[...]'

  @massage: (email, options) ->
    @cleanMessage email
    @setThreadId email, options

  @cleanMessage: (email) ->
    throw pjson(message) if email.id?  # make sure there is no @email.id already
    email.id = email.headers?['message-id']
    email.valid = email.id?
    email.cleanText = escapeHtml @cleanText email.text
    email.fromName = email.from?[0]?.name or email.from?[0]?.address
    email.subject = email.subject.replace /^(\bRe\b|\bFwd\b|:|\[|\]| )+\s*/i, ''
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
      .replace /(--)?\s*You received this message because you are subscribed to the Google Group(.|\n)*/, ''
      .replace /(--)?\s*To post to this group, send email to (.|\n)*/, ''
      .replace /(--)?\s*To unsubscribe from this group and stop receiving emails from it, send an email to (.|\n)*/, ''
      .replace /(--)?\s*You received this message because you are subscribed to the Google Groups (.|\n)*/, ''
      .replace /(\n\s*(From|Sent|Cc|Date|To|Subject|Bcc): .+){3}(.|\n)*/, ''
      .replace ///\s*On .+ \d{4} .+, .+ wrote:(.|\n)*///, ''
      .replace /\n\s*>.*?$/gm, ''   # lines beginning with >
      .replace ///<?#{EMAIL_PATTERN}\s?<mailto:#{EMAIL_PATTERN}>>?///gi, REMOVED
      .replace ///<mailto:#{EMAIL_PATTERN}>///gi, REMOVED
      .replace ///<?#{EMAIL_PATTERN}>?///gi, REMOVED
      .replace /\[Image removed by sender\.\]\s*<\S+>/gi, REMOVED

module.exports = Email
