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

  request('https://www.google.com/calendar/render?pli=1#g', (err, response) ->
    if err
      console.log(err)
    console.log(response.responseObj.html())
  )