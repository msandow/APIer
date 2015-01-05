async = require('async')
util = require(__dirname + '/../lib/utilities.coffee')
fs = require('fs')
console = require(__dirname + '/../lib/console.coffee')

process.env.TZ = 'America/Los_Angeles'

ROOT = exports ? this
ROOT.WARMING = false

search =
  search: ['javascript','developer']
  negative: ['.net','ios','rails','python','ruby','android', 'salesforce', 'junior', 'mobile', 'wordpress', 'j2ee', 'manager',
  'java', 'dba', 'consultant', 'plm', 'cq', 'admin', 'analyst', 'contract', 'intern', 'jsp', 'recruiting', 'informatica', 'asp.net',
  'drupal', 'netezza', 'teradata', 'django', 'haskell', 'smarty', 'designer', 'opencl']
  companies: ['android', 'group', 'ascendify', 'ampush', 'zynga', 'mulesoft', 'mindjet', 'imgur', 'mashape',
  'plastiq', 'humble', 'software', 'weebly', 'zipongo',
  'hellosign', '5th finger','lynda','balluun','capital one', 'infoobjects', 'bizlol', 'minted',
  'gliffy', 'corvisacloud', 'drishticon', 'quardev', 'osi', 'twilio', 'deegit', 'moodys', 'ideahelix', 'employment', 
  'macys', 'macy\'s', 'insight global', 'tellapart', 'continuum', 'tokbox', 'peanut labs', 'buffer', 'celtra', 'opentable']
  #'cybercoders', 'accenture', 'technology', 'solutions', 'active soft', 'staffing', 'vircon', 'ziprecruiter', 'ampush', 'jobvite', 'beyondsoft', 'technologies', 'recruiting'
  location: 'san francisco'
  filterLocations: ['palo alto', 'oakland', 'sausalito', 'san jose', 'redwood city', 'emeryville', 'menlo park', 'san carlos',
  'moutain view', 'hayward', 'sunnyvale', 'santa clara', 'san mateo', 'foster city', 'south san francisco', 'burlingame', 'san rafael',
  'san bruno', 'milpitas', 'brisbane']
  days: 1
  nice: ['coffee', 'independent', 'salary', 'generious', 'fun', 'fast', 'catered', 'small', 'beer', 'node', 'php', 'startup',
  'start-up', 'start up', 'travel', 'europe']
  bad: ['angular', 'angularjs', '8+', '8 years', 'agile', 'angular.js', 'advertising', 'symfony', 'CS fundamentals', 'education',
  'marketing', 'a/b testing']
  blacklist: ['e5ba4b423775959223e3144f73b633fa', '407eecf081b9f16ddfd92c84eafc0660', 'c447dc52b29e51940609a805d34bcd14',
  'd5f1377b8ee9d6c53a9401bcf2e57bf4', 'f86dc3fa0a73649823d3e075ca9f04e0', 'f7e5dcb6d1be6dfe44c7dff5f76997cc',
  '5c18c302fa8f1e53d6dbd115b67583cd', 'b3c52a9fb4d3304e0446a9651e3954af', '7e70a1e6915ac2698e07eff38a519332',
  'ec3185f4e91ed3975aa680a2c60f9f27', 'a78bf388a930bbbbace1b5fcc2dd81c1', '352412fd827d7ab0598640d6a86eb097',
  '72885c1c0d85a021aafbc0ae91554b20', '533847d8128dbc3c60a1e91293c543e0', '4dcc6d7fa189a6ff8f12a80601515923',
  'c9ed7c2a7d6beae50a6169bffc27468f', '01fc7523f53c620b19c79a7be547e143', 'eee89a790a33e3bc0c35b55ebedec1f0',
  '49ca5b4acccfac004d6e6c5c2a4d5459', '3b4f1f53e11db07e8d0872cb845430d9']

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