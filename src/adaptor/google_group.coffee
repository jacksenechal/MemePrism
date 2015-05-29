Nightmare = require 'nightmare'
{ log, p } = require 'lightsaber'

class GoogleGroup
  topicSelector = '.LOFA24-rb-h'

  read: (groupName) ->
    browser = new Nightmare
    url = "https://groups.google.com/forum/#!forum/#{groupName}"
    browser
    .goto url
    .wait() # topicSelector (multiple?)
    .screenshot "tmp/#{groupName}" #"-#{(new Date).toISOString()}.png")
    .evaluate \
          (-> document.querySelectorAll '.LOFA24-rb-h'),
          (links) -> log links #(log link.href) for link in links
    .run (err) ->
      if err
        return console.log(err)
      console.log 'Done!'

module.exports = GoogleGroup
