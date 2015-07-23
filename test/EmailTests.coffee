require('chai').should()
lightsaber = require 'lightsaber'
{ log, p } = lightsaber

Email = require '../src/adaptor/email'

describe 'cleanText', ->
  it "should remove <mailto:*>", ->
    text = "our emails: <mailto:bunny@example.com> and <mailto:santa@example.com>"
    cleanText = Email.cleanText text
    cleanText.should.equal "our emails: [...] and [...]"

  it "should remove email addresses", ->
    text = "our emails: bunny@example.com,<santa@x.com>, x.y-Z_3@a.b.c.academy: yup"
    cleanText = Email.cleanText text
    cleanText.should.equal "our emails: [...],[...], [...]: yup"

  it "should remove google groups style email addresses", ->
    emails = [
      "<da...@iiij.org <mailto:da...@iiij.org>>"
      '<ik...@bsi.com.au<mailto:ik...@bsi.com.au>>'
      '<Marjory_S_...@ostp.eop.gov<mailto:Marjory_S_...@ostp.eop.gov>>'
      'i4j...@i4jsummit.org<mailto:i4j...@i4jsummit.org>'
    ]
    for email in emails
      cleanText = Email.cleanText email
      cleanText.should.equal "[...]"

# To unsubscribe from this group and stop receiving emails from it, send an email to […].
# To post to this group, send email to […].
# Visit this group at >http://groups.google.com/a/i4jsummit.org/group/i4j2015/<<%3ehttp:/groups.google.com/a/i4jsummit.org/group/i4j2015/%3c>

# [Image removed by sender.]<%3ehttp:/www.facebook.com/rawdigital%3c> [Image removed by sender.] <%3ehttps:/twitter.com/%3c#%21/rawmedianetwork> [Image removed by sender.] <%3ehttp:/www.youtube.com/user/RawDigitaltv%3c>

# On Mon, Mar 23, 2015 at 12:16 PM, Jordan Greenhall <[…] wrote
