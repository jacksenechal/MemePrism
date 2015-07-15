require('chai').should()
lightsaber = require 'lightsaber'
{ log, p } = lightsaber

Wordpress = require '../src/adaptor/wordpress'

describe 'cleanText', ->
  before ->
    @wordpress = new Wordpress

  it "should remove <mailto:*>", ->
    text = "our emails: <mailto:bunny@example.com> and <mailto:santa@example.com>"
    cleanText = @wordpress.cleanText text
    cleanText.should.equal "our emails: <(removed)> and <(removed)>"

  it "should remove email addresses", ->
    text = "our emails: bunny@example.com,santa@x.com, x.y-Z_3@a.b.c.academy: yup"
    cleanText = @wordpress.cleanText text
    cleanText.should.equal "our emails: <(removed)>,<(removed)>, <(removed)>: yup"
