core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class linkedinParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join('-').replace(/\s/g, '-')).replace('{{location}}',@search.location.replace(/\s/g, '-'))

module.exports = () ->
  new linkedinParser(
    listingURL: 'https://www.linkedin.com/job/{{search}}-jobs-{{location}}-ca/?sort=date&trk=jserp_sort_date'
    listingParser: (dom)->
      listings = []
      self = this
      
      dom('li.job').each(->
        listings.push(new obj(
            dom(@).find('a.title').text(),
            dom(@).find('a.company').text(),
            dom(@).find('a.title').attr('href'),
            self.timeParser(dom(@).find('.fnt20').text())
          )
        )
      )

      listings
  )