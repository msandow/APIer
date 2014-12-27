core = require('./core.coffee')
obj = require('./../listingObject.coffee')
cheerio = require('cheerio')

class diceParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join(' ')).replace('{{location}}',@search.location)
    .replace('{{negative}}', @search.negative.map((i)-> '-'+i).join(' '))

module.exports = () ->
  new diceParser(
    listingURL: 'https://www.dice.com/jobs/filters?inputJSON={"q":"{{search}} {{negative}}","l":"{{location}}","limit":100,"sort":"date"}'
    listingParser: (dom)->
      dom = cheerio.load(dom.searchResults)
      
      listings = []
      self = this
      
      dom('.serp-result-content').each(->
        listings.push(new obj(
            dom(@).find('h3 a').text()
            dom(@).find('.employer a').text()
            dom(@).find('h3 a').attr('href')
            self.timeParser(dom(@).find('.posted').text())
          )
        )
      )

      listings
  )