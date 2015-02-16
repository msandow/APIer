core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class techcareersParser extends core
  buildListingPageURL: ()->
    @postData =
      FNationwideBoxShown:'Y'
      FSearchArea:'advanced'
      FRegion:''
      soid:6
      FKeywords:@search.search.join(' ')
      FSearchType:2
      FWhere:@search.location
      FRadius:50
      FCountryState:''
      FAreaCode1:''
      FAreaCode2:''
      FAreaCode3:''
      FOrderBy:1
      FAddAlert:'N'
  
    @listingURL

module.exports = () ->
  new techcareersParser(
    type: 'POST'
    listingURL: 'http://www.techcareers.com/jobs/search'
    listingParser: (dom)->
      listings = []
      self = this
      
      dom('.job[data-jobid]').each(->
        listings.push(new obj(
            dom(@).find('h4.theme-primary-link-color').text(),
            dom(@).find('.job-title-company span').eq(0).text(),
            dom(@).find('a[itemprop="url"]').attr('href'),
            self.timeParser(dom(@).find('time[itemprop="datePosted"]').text())
          )
        )
      )

      listings
  )