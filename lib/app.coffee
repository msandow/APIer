CronJob = require('cron').CronJob
async = require('async')
util = require('./utilities.coffee')

search =
  search: ['developer','javascript']
  negative: ['.net','ios','rails','python']
  location: 'san francisco'
  days: 3

mySearch = require(__dirname + '/searchObject.coffee')(search)

cl = require(__dirname + '/scrapers/craigslist.coffee')()
cl.setSearch(mySearch)

cb = require(__dirname + '/scrapers/careerbuilder.coffee')()
cb.setSearch(mySearch)

module.exports = () ->

#  testJob = new CronJob(
#    cronTime: '00 */1 * * * *'
#    onTick: () ->
#      console.log(new Date().getTime())
#    start: false
#    timeZone: 'America/Los_Angeles'
#  )
#  
#  testJob.start()
  
  async.series({
    Craigslist: (done)->
      cl.fetch(done)
    CareerBuilder: (done)->
      cb.fetch(done)
  },
  (err, response)->
    results = util.merge(response.Craigslist, response.CareerBuilder)
    results = util.uniqueObjsBy(results, 'positionHash').sort((a, b)->
      if a.time > b.time then -1 else if a.time < b.time then 1 else 0
    )

    console.log(results.length)
  )