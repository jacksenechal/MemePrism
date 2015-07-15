require('chai').should()
lightsaber = require 'lightsaber'
{ log, p } = lightsaber

Wordpress = require '../src/adaptor/wordpress'

describe 'cleanText', ->
  before ->
    @wordpress = new Wordpress

  it "should remove mailto: links", ->
    text = "our emails: <mailto:bunny@example.com> and <mailto:santa@example.com>"
    cleanText = @wordpress.cleanText text
    cleanText.should.equal "our emails: <(removed)> and <(removed)>"
