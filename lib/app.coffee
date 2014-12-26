CronJob = require('cron').CronJob
request = require('./request.coffee')
mapper = require('./mapper.coffee')

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

  request.make('http://sfbay.craigslist.org/search/sss', (err, response) ->
    if err
      console.log(err)
    #d.val=arrayOf(range("span.pl a",0,1),(->{text: @text()}))
    mapper.query('d.val=object((->{links: @(".rightpane .row[data-pid]").length, title: @("title").text()}))', response.responseObj, (data)->
      console.log(data)
    )
  )