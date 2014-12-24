CronJob = require('cron').CronJob
request = require('./request.coffee')

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

  request('http://www.reddit.com/r/startups/?count=150&after=t3_2pf6pb', (err, response) ->
    console.log(response)
  )