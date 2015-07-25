require('chai').should()
lightsaber = require 'lightsaber'
{ log, p } = lightsaber

Email = require '../src/adaptor/email'

describe 'cleanMessage', ->
  it "should remove subject prefixes", ->
    email =
      text: ''
      from: [name: 'me']
      date : 'now'
    subjects = [
      "subject"
      "Re: subject"
      "Fwd: subject"
      "Re: Fwd: subject"
      "Re: [Fwd: [subject"
    ]
    for subject in subjects
      email.subject =  subject
      Email.cleanMessage email
      email.subject.should.equal "subject"

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

  it "should remove google group footers and below", ->
    text = """
    foo
    You received this message because you are subscribed to the Google Group
    bar
    """
    cleanText = Email.cleanText text
    cleanText.should.equal "foo"

  it "should remove group footers and below", ->
    text = """
    foo
    To post to this group, send email to […].
    Visit this group at >http://groups.google.com/a/i4jsummit.org/group/i4j2015/<<%3ehttp:/groups.google.com/a/i4jsummit.org/group/i4j2015/%3c>
    bar
    """
    cleanText = Email.cleanText text
    cleanText.should.equal "foo"

  it "should remove forwarded emails", ->
    text = """
    foo
    On Tue, Jul 7, 2015 at 2:03 AM, Curt Carlson <curt@practiceofinnovation.com> wrote:
    bar
    """
    cleanText = Email.cleanText text
    cleanText.should.equal "foo"

  it "should remove forwarded email blocks", ->
    text = """
    foo
    From: C Carlson <cu...@practiceofinnovation.com<mailto:cu...@practiceofinnovation.com>>
    Sent: Sunday, March 08, 2015 12:09 PM
    To: Stephen Denning <st...@stevedenning.com<mailto:st...@stevedenning.com>>, Jordan Greenhall <jordan.g...@gmail.com<mailto:jordan.g...@gmail.com>>
    bar
    """
    cleanText = Email.cleanText text
    cleanText.should.equal "foo"

  it "should remove forwarded email blocks", ->
    text = """
    foo
    Cc: Philip Auerswald <philip.a...@gmail.com<mailto:philip.a...@gmail.com>>, Herman Gyr <G...@Enterprisedevelop.Com<mailto:G...@Enterprisedevelop.Com>>, Ivan Kaye <ik...@bsi.com.au<mailto:ik...@bsi.com.au>>, i4j Mountain View 2015 <i4j...@i4jsummit.org<mailto:i4j...@i4jsummit.org>>, David Nordfors <da...@iiij.org<mailto:da...@iiij.org>>
    Date: Tuesday, June 2, 2015 at 5:55 AM
    Subject: Re: [i4j2015] The Bifurcation is Near
    bar
    """
    cleanText = Email.cleanText text
    cleanText.should.equal "foo"

  it "should remove (removed) image links", ->
    crufts = [
      '[Image removed by sender.]<%3ehttp:/www.facebook.com/rawdigital%3c>'
      '[Image removed by sender.] <%3ehttps:/twitter.com/%3c#%21/rawmedianetwork>'
    ]
    for cruft in crufts
      clean = Email.cleanText cruft
      clean.should.equal "[...]"
