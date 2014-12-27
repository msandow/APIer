CronJob = require('cron').CronJob
async = require('async')
util = require('./utilities.coffee')
fs = require('fs')

search =
  search: ['developer']
  negative: ['.net','ios','rails','python','ruby','android', 'salesforce', 'junior', 'mobile', 'wordpress', 'j2ee', 'manager', 'dba', 'consultant']
  companies: ['cybercoders', 'accenture', 'technology', 'solutions', 'active soft', 'staffing',
  'android', 'group', 'ascendify', 'ampush', 'zynga', 'mulesoft', 'mindjet', 'imgur', 'mashape',
  'plastiq', 'humble', 'software', 'weebly', 'zipongo',
  'hellosign', '5th finger','lynda','balluun','capital one', 'infoobjects', 'bizlol', 'minted',
  'ziprecruiter', 'vircon', 'gliffy', 'ampush', 'gliffy', 'jobvite']
  location: 'san francisco'
  filterLocations: ['palo alto', 'oakland', 'sausalito', 'san jose', 'redwood city', 'emeryville',
  'moutain view', 'hayward', 'sunnyvale', 'santa clara', 'san mateo', 'foster city']
  days: 3

mySearch = require(__dirname + '/searchObject.coffee')(search)

queue = []

fs.readdirSync(__dirname + '/scrapers/').forEach((file)->
  if file isnt 'core.coffee'
    tr = require(__dirname + '/scrapers/' + file)()
    tr.setSearch(mySearch)
    
    queue.push((done)->
      tr.fetch(done)
    )
)

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
  
  async.series(queue,
  (err, response)->
    merged = []
    for r in response
      merged = util.merge(merged, r)

    merged = util.uniqueObjsBy(merged, 'positionHash').sort((a, b)->
      return  1 if a.time < b.time
      return -1 if a.time > b.time
      return  1 if a.title > b.title
      return -1 if a.title < b.title
      return 0
    )

    console.log(merged.length)
  )