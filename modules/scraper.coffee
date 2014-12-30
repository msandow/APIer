async = require('async')
util = require(__dirname + '/../lib/utilities.coffee')
fs = require('fs')
console = require(__dirname + '/../lib/console.coffee')

process.env.TZ = 'America/Los Angeles'

ROOT = exports ? this
ROOT.WARMING = false

search =
  search: ['javascript','developer']
  negative: ['.net','ios','rails','python','ruby','android', 'salesforce', 'junior', 'mobile', 'wordpress', 'j2ee', 'manager',
  'java', 'dba', 'consultant', 'plm', 'cq', 'admin', 'analyst', 'contract', 'intern', 'jsp', 'recruiting', 'informatica', 'asp.net',
  'drupal', 'netezza', 'teradata', 'django']
  companies: ['android', 'group', 'ascendify', 'ampush', 'zynga', 'mulesoft', 'mindjet', 'imgur', 'mashape',
  'plastiq', 'humble', 'software', 'weebly', 'zipongo',
  'hellosign', '5th finger','lynda','balluun','capital one', 'infoobjects', 'bizlol', 'minted',
  'gliffy', 'corvisacloud', 'drishticon', 'quardev', 'osi', 'twilio', 'deegit', 'moodys', 'ideahelix', 'employment', 
  'macys', 'macy\'s', 'insight global', 'tellapart', 'continuum']
  #'cybercoders', 'accenture', 'technology', 'solutions', 'active soft', 'staffing', 'vircon', 'ziprecruiter', 'ampush', 'jobvite', 'beyondsoft', 'technologies', 'recruiting'
  location: 'san francisco'
  filterLocations: ['palo alto', 'oakland', 'sausalito', 'san jose', 'redwood city', 'emeryville', 'menlo park', 
  'moutain view', 'hayward', 'sunnyvale', 'santa clara', 'san mateo', 'foster city', 'south san francisco', 'burlingame']
  days: 2
  nice: ['coffee', 'independent', 'salary', 'generious', 'fun', 'fast', 'catered', 'small', 'beer', 'node', 'php', 'startup',
  'start-up', 'start up']
  bad: ['angular', 'angularjs', '8+', '8 years', 'agile', 'angular.js', 'advertising']
  blacklist: ['8d373576dc21863292893f74b17edfde','9fb7134702ad2a26cc3b2609b87d2d51','821767ca685bf82a7d521f8671321c46',
  'd5ab900a69016832dbe63c85607aa894', '26875fbfa040f5709eb8a790965b3513','08a274bcdd7bfa44959e7891fb7e2f2d',
  '6ff729deef03696ca676c29eca91a99d', 'bc5c494de8facfa0c07cdc391c397c74', '57251fc9a883f9196de1e1f190f22c6b',
  '81cfc41b7b3fbdf9794fc36b1b9a4bd1', 'c77695820f9679fd1aab468deac9e2f8']

mySearch = require(__dirname + '/../lib/searchObject.coffee')(search)

fetchqueue = []
warmqueue = []

fs.readdirSync(__dirname + '/../lib/scrapers/').forEach((file)->
  if file isnt 'core.coffee'
    tr = require(__dirname + '/../lib/scrapers/' + file)()
    tr.setSearch(mySearch)

    fetchqueue.push((done)->
      tr.fetch(done)
    )

    warmqueue.push((done)->
      tr.warm(done)
    )
)

fetchQueue = (cb)->
  if not ROOT.WARMING
    async.series(fetchqueue,
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

      cb(merged)
    )
  else
    cb([])

warmQueue = (cb)->
  if not ROOT.WARMING
    ROOT.WARMING = true
    async.series(warmqueue,
    (err, response)->
      ROOT.WARMING = false
      console.log('Cache warm')
      cb(err or response)
    )

module.exports =
  lastUpdated: new Date(), 
  start: (onReady)->
    self = this
    maxDirSize = 0
    currDirSize = 0
    dir = __dirname + '/../lib/__cache/'
    
    fs.exists(dir, (exists)->
      if exists
        fs.readdir(dir, (err, files)->
          for f in files
            size = fs.statSync(dir + f).size
            size = size / 1000000.0
            if currDirSize < maxDirSize
              currDirSize += size
            else
              fs.unlinkSync(dir + f) 

          warmQueue((response)->
            setInterval(()->
              warmQueue((response)->
                console.info(response)
                self.lastUpdated = new Date()
              )
            , 1000 * 60 * 30)
          )
        )
      else
        warmQueue((response)->
          setInterval(()->
            warmQueue((response)->
              console.info(response)
              self.lastUpdated = new Date()
            )
          , 1000 * 60 * 30)
        )
    )
    
    onReady()
    
  fetch: (done)->
    fetchQueue(done)