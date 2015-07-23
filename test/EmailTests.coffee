require('chai').should()
lightsaber = require 'lightsaber'
{ log, p } = lightsaber

Email = require '../src/adaptor/email'

describe 'cleanText', ->
  it "should remove <mailto:*>", ->
    text = "our emails: <mailto:bunny@example.com> and <mailto:santa@example.com>"
    cleanText = Email.cleanText text
    cleanText.should.equal "our emails: <(removed)> and <(removed)>"

  it "should remove email addresses", ->
    text = "our emails: bunny@example.com,santa@x.com, x.y-Z_3@a.b.c.academy: yup"
    cleanText = Email.cleanText text
    cleanText.should.equal "our emails: <(removed)>,<(removed)>, <(removed)>: yup"
