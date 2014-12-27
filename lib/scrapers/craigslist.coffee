core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class craigslistParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join('+'))
    .replace('{{negative}}', @search.negative.map((i)-> '-'+i).join('+'))

module.exports = () ->
  new craigslistParser(
    listingURL: 'http://sfbay.craigslist.org/search/jjj/?sort=date&query={{search}}{{negative}}'
    listingParser: (dom)->
      listings = []
      self = this

      dom('p[data-pid]').each(->
        listings.push(new obj(
            dom(@).find('.hdrlnk').text(),
            null,
            dom(@).find('.hdrlnk').attr('href'),
            self.timeParser(dom(@).find('time').attr('datetime'))
          )
        )
      )

      listings
  )