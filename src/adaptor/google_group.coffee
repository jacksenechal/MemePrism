coffee = require 'coffee-script'
Nightmare = require 'nightmare'
{ log, p } = require 'lightsaber'

class GoogleGroup
  read: (groupName) ->
    browser = new Nightmare
    url = "https://groups.google.com/forum/#!forum/#{groupName}"
    browser
    .goto url
    .wait() # '.LOFA24-p-Q'
    .evaluate \
          (-> document.querySelectorAll '.LOFA24-p-Q'),
          (links) -> (log link?.href) for link in links
    .run (err) ->
      if err
        return console.log(err)
      console.log 'Done!'

module.exports = GoogleGroup
