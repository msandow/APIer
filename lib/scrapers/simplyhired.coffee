core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class simplyhiredParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join('+')).replace('{{location}}',@search.location.replace(/\s/g, '+'))
    .replace('{{negative}}', @search.negative.join('+'))

module.exports = () ->
  new simplyhiredParser(
    listingURL: 'http://www.simplyhired.com/search?qa={{search}}&qw={{negative}}&lc={{location}}&fem=employer&ws=50&sb=dd'
    listingParser: (dom)->
      listings = []
      self = this
      
      dom('li.result .job').each(->
        listings.push(new obj(
            dom(@).find('h2 a').text(),
            dom(@).find('h4.company').text(),
            dom(@).find('h2 a').attr('href').replace(/rid-[a-zA-Z0-9]+/gi, 'rid-'),
            self.timeParser(dom(@).find('.source .ago').text())
          )
        )
      )

      listings
  )