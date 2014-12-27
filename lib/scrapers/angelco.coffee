core = require('./core.coffee')
obj = require('./../listingObject.coffee')
request = require('./../request.coffee')

class linkedinParser extends core
  getListingLinks: (listingPage, cb)->
    json = listingPage.responseObj
    request.make('https://api.angel.co/1/tags/'+json[0].id+'/jobs', (err, response)=>
      if response.headers['x-ratelimit-remaining'] < 1
        response.responseObj = 
          jobs: []

      collection = @listingParser(response.responseObj.jobs).filter(@listingFilter)
      cb(null, collection)
    )

  fetchContent: (links, cb)->
    cb(links)

  buildListingPageURL: ()->
    @listingURL.replace('{{location}}',@search.location)

module.exports = () ->
  new linkedinParser(
    listingURL: 'https://api.angel.co/1/search?query={{location}}&type=LocationTag'
    listingParser: (dom)->
      listings = []
      self = this

      for d in dom
        oo = new obj(
          d.title,
          d.startup.name,
          d.angellist_url,
          self.timeParser(d.updated_at)
        )

        oo.content = d.description

        listings.push(oo)

      listings
  )