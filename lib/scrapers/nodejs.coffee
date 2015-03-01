core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class nodeJSParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join('+').replace(/\s/g, '+')).replace(/\{\{location\}\}/g,@search.location.replace(/\s/g, '+'))

module.exports = () ->
  new nodeJSParser(
    listingURL: 'http://jobs.nodejs.org/a/jobs/list/q-{{search}}/l-{{location}}%2C+ca/mi-50/fdb-7/fem-employer/ws-10/sb-dd/fsr-primary'
    listingParser: (dom)->
      listings = []
      self = this

      dom('.job[itemscope]').each(->
        listings.push(new obj(
            dom(@).find('a.title').text(),
            dom(@).find('h4.company').last().text(),
            dom(@).find('a.title').attr('href'),
            self.timeParser(dom(@).find('span.ago').text())
          )
        )
      )

      listings
  )