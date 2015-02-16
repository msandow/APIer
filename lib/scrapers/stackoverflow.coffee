core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class stackoverflowParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join('+')).replace('{{location}}',@search.location.replace(/\s/g, '+'))

module.exports = () ->
  new stackoverflowParser(
    listingURL: 'http://careers.stackoverflow.com/jobs?searchTerm={{search}}&type=permanent&location={{location}}&range=50&distanceUnits=Miles&sort=p'
    listingParser: (dom)->
      listings = []
      self = this
      
      dom('.-company-group').each(->
        company = dom(@).find('.-company h2 a').text()
        
        dom(@).find('.-job').each(->
        listings.push(new obj(
            dom(@).find('h3 a').text(),
            company,
            dom(@).find('h3 a').attr('href'),
            self.timeParser(dom(@).find('p.date-posted').text())
          )
        )
        )
      )

      listings
  )