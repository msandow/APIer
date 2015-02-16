core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class indeedParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join(' ')).replace('{{location}}',@search.location)
    .replace('{{negative}}', @search.negative.join(' '))

module.exports = () ->
  new indeedParser(
    listingURL: 'http://www.indeed.com/jobs?as_any=&as_phr=&as_and={{search}}&as_not={{negative}}&as_ttl=&as_cmp=&jt=fulltime&st=&sr=directhire&salary=&radius=50&l={{location}}&fromage=any&limit=50&sort=date&psf=advsrch'
    listingParser: (dom)->
      listings = []
      self = this
      
      dom('.result[itemscope]').each(->
        listings.push(new obj(
            dom(@).find('.jobtitle a').text(),
            dom(@).find('.company span').text(),
            dom(@).find('.jobtitle a').attr('href'),
            self.timeParser(dom(@).find('.date').text())
          )
        )
      )

      listings
  )