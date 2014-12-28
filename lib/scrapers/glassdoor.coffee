core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class glassdoorParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join('-')).replace('{{location}}',@search.location.replace(/\s/g, '-'))

module.exports = () ->
  new glassdoorParser(
    listingURL: 'http://www.glassdoor.com/Job/ajax/{{location}}-{{search}}-jobs-SRCH_IL.0,13_IC1147401_KO14,34.htm?radius=25&fromAge=7&minRating=3.0&jobType=all&brandedAO=0'
    listingParser: (dom)->
      listings = []
      self = this
      
      dom('.jobScopeWrapper[itemtype]').each(->
        listings.push(new obj(
            dom(@).find('a.jobLink tt').text(),
            dom(@).find('.employerName tt.i-emp').text(),
            dom(@).find('a.jobLink').attr('href').replace(/&cb=\d+/gi, '').replace(/guid=[0-9a-fA-F]+/gi, 'guid=').replace(/extid=\d+/gi, 'extid='),
            self.timeParser(dom(@).find('.minor').text())
          )
        )
      )

      listings
  )