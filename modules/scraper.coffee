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
  'drupal', 'netezza', 'teradata', 'django', 'haskell', 'smarty', 'designer']
  companies: ['android', 'group', 'ascendify', 'ampush', 'zynga', 'mulesoft', 'mindjet', 'imgur', 'mashape',
  'plastiq', 'humble', 'software', 'weebly', 'zipongo',
  'hellosign', '5th finger','lynda','balluun','capital one', 'infoobjects', 'bizlol', 'minted',
  'gliffy', 'corvisacloud', 'drishticon', 'quardev', 'osi', 'twilio', 'deegit', 'moodys', 'ideahelix', 'employment', 
  'macys', 'macy\'s', 'insight global', 'tellapart', 'continuum']
  #'cybercoders', 'accenture', 'technology', 'solutions', 'active soft', 'staffing', 'vircon', 'ziprecruiter', 'ampush', 'jobvite', 'beyondsoft', 'technologies', 'recruiting'
  location: 'san francisco'
  filterLocations: ['palo alto', 'oakland', 'sausalito', 'san jose', 'redwood city', 'emeryville', 'menlo park', 'san carlos',
  'moutain view', 'hayward', 'sunnyvale', 'santa clara', 'san mateo', 'foster city', 'south san francisco', 'burlingame']
  days: 1
  nice: ['coffee', 'independent', 'salary', 'generious', 'fun', 'fast', 'catered', 'small', 'beer', 'node', 'php', 'startup',
  'start-up', 'start up']
  bad: ['angular', 'angularjs', '8+', '8 years', 'agile', 'angular.js', 'advertising', 'symfony']
  blacklist: ['95089f925e902c47d3a4a770db16f2c7', '9f0119cc666c06d8fe73fd9d9a988604', 'ef51444816437535807311eee370758d',
  '5619532fd28d87cd66112a999f5c1573', '9843dfe483a786eacee693f16e18bf15',
  '1002b05137f45848b4e00e8c9bf3af14', 'c744eb61101ed3fa5e1d6bb997c88964','38301a2cbef96bdf63e1c07a4ccceee8',
  'e5ba4b423775959223e3144f73b633fa', '407eecf081b9f16ddfd92c84eafc0660', 'c447dc52b29e51940609a805d34bcd14',
  'd5f1377b8ee9d6c53a9401bcf2e57bf4', 'f86dc3fa0a73649823d3e075ca9f04e0 ']

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