async = require('async')
request = require('./../request.coffee')
hash = require('./../hash.coffee')
console = require('./../console.coffee')
cache = require('./../cache.coffee')
fs = require('fs')

class ScraperCore
  constructor: (configs = {})->
    @listingURL = configs.listingURL or 'localhost'
    @listingParser = configs.listingParser or ((dom)->[])
    @search = false
    true
  
  setSearch: (search)->
    @search = search
  
  timeParser: (str) =>
    str = str.toLowerCase().trim().replace(/posted:\s+/i,'')
    curr = new Date()
    map = new Date()

    map.setHours(0)
    map.setMinutes(0)
    map.setSeconds(0)
    map.setMilliseconds(0)

    if /^\d+\sday/.test(str)
        i = parseInt(str)
        map.setDate(curr.getDate()-i)
    else if /\d{4}-\d{1,2}-\d{1,2}\s\d+/.test(str)
        arr = str.split(' ')
        arr[0] = arr[0].split('-').map((i)-> parseInt(i))
        arr[1] = arr[1].split(':').map((i)-> parseInt(i))

        map.setFullYear(arr[0][0], arr[0][1]-1, arr[0][2])
        map.setHours(arr[1][0], arr[1][1])
    else if /[a-z]{3,4}-\d{1,2}-\d{4}/.test(str)
        arr = str.split('-')

        switch(arr[0])
            when 'jan'
                map.setMonth(0)
            when 'feb', 'febr'
                map.setMonth(1)
            when 'mar'
                map.setMonth(2)
            when 'apr'
                map.setMonth(3)
            when 'may'
                map.setMonth(4)
            when 'jun', 'june'
                map.setMonth(5)
            when 'jul', 'july'
                map.setMonth(6)
            when 'aug'
                map.setMonth(7)
            when 'sep', 'sept'
                map.setMonth(8)
            when 'oct'
                map.setMonth(9)
            when 'nov'
                map.setMonth(10)
            when 'dec'
                map.setMonth(11)                                    

        map.setDate(parseInt(arr[1]))
        map.setFullYear(parseInt(arr[2]))
    else if /\d{1,2}\/\d{1,2}\/\d{4}/.test(str)
        arr = str.split('/').map((i)-> parseInt(i))

        map.setFullYear(arr[2],arr[0]-1,arr[1])
    else if str is 'yesterday'
        map.setDate(curr.getDate()-1)
    else if /^\d+\sweek/.test(str)
        i = parseInt(str)
        map.setDate(curr.getDate()-(i*7))
    else if /^\d{4}/.test(str)
        str = str.replace('t00:00:00.0000000','')
        map.setTime(Date.parse(str))

    #if isNaN( map.getTime() )
        #console.log(str)

    map

  contentParser: (ob, origin) =>
    for s in ['#pnlJobDescription', '#job_body_box', '.pjb-box-inner:first', 'section.userbody', '.dc_content', '#detailDescription', '.jobdetail', '.detail:first', '.job_description', '.jobDescriptionContent', '.jvdescriptionbody', '#js-job-description', '#content', '.des_content', '#lbljobdesc', '.iCIMS_JobPage', '.content:first', '#job_summary', '.job-details', '.jobDetailContent', '#jobDesciptionDiv', '#jobcopy', '#job_desc']
      ss = s.replace(':first','')
      if ob(ss).length
        if s.indexOf(':first') > -1
          o = ob(ss).eq(0)
        else
          o = ob(ss)

        return o.text().replace(/\s{2,}|\t|\r|\n|\r\n/g,'')

    console.warn('Content unable to be parsed for',origin)

    false

  buildListingPageURL: ()->
    @listingURL
  
  getListingPage: (cb, withCache)->
    request.make(@buildListingPageURL(), (err, response)->
      cb(err, response)
    )
  
  getListingLinks: (listingPage, cb)->
    dom = listingPage.responseObj
    collection = @listingParser(dom).filter((c)=>
      d = new Date()
      d.setHours(0,0,0,0)
      d.getTime() - c.time <= (@search.days * 86400000)
    )
    cb(null, collection)
    
  fetchContent: (links, cb)->
    self = this
  
    jobs = links.map((j)->
      (_cb)->
        request.make(j.link, (err, response)->
          j.content = self.contentParser(response.responseObj, j.link)
          _cb(null,j)
        )
    )

    async.parallelLimit(jobs, 2, (error, response)->
      cb(links)
    )
  
  warm: (cb)->
    cache.clear(@buildListingPageURL(),()=>
      @getListingPage((listingErr, listingResponse)=>
        @getListingLinks(listingResponse, (linksErr, linksResponse)=>
          @fetchContent(linksResponse, (objResponse)->
            cb(null, true)
          )
        )
      )
    )
  
  fetch: (done)->
    @getListingPage((listingErr, listingResponse)=>
      @getListingLinks(listingResponse, (linksErr, linksResponse)=>
        @fetchContent(linksResponse, (objResponse)->
          done(null, objResponse)
        )
      )
    )
    
module.exports = ScraperCore