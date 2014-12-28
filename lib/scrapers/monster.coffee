core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class monsterParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join(',').replace(/\s/g, '-')).replace(/\{\{location\}\}/g,@search.location.replace(/\s/g, '-'))

module.exports = () ->
  new monsterParser(
    listingURL: 'http://jobsearch.monster.com/search/{{location}}+Full-Time_128?tm=Last-14-Days&q={{search}}&where={{location}}&rad=20-miles&sort=dt.rv.di'
    listingParser: (dom)->
      listings = []
      self = this

      dom('.listingsTable tbody tr[class]').each(->
        listings.push(new obj(
            dom(@).find('a.slJobTitle').text(),
            dom(@).find('.companyContainer a').last().text(),
            dom(@).find('a.slJobTitle').attr('href'),
            self.timeParser(dom(@).find('.fnt20').text())
          )
        )
      )

      listings
  )