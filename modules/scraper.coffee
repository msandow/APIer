async = require('async')
util = require(__dirname + '/../lib/utilities.coffee')
fs = require('fs')
console = require(__dirname + '/../lib/console.coffee')

ROOT = exports ? this
ROOT.WARMING = false

search =
  search: ['javascript','developer']
  negative: ['.net','ios','rails','python','ruby','android', 'salesforce', 'junior', 'mobile', 'wordpress', 'j2ee', 'manager',
  'java', 'dba', 'consultant', 'plm', 'cq', 'admin', 'analyst', 'contract', 'intern', 'jsp', 'recruiting', 'informatica', 'asp.net',
  'drupal']
  companies: ['cybercoders', 'accenture', 'technology', 'solutions', 'active soft', 'staffing',
  'android', 'group', 'ascendify', 'ampush', 'zynga', 'mulesoft', 'mindjet', 'imgur', 'mashape',
  'plastiq', 'humble', 'software', 'weebly', 'zipongo',
  'hellosign', '5th finger','lynda','balluun','capital one', 'infoobjects', 'bizlol', 'minted',
  'ziprecruiter', 'vircon', 'gliffy', 'ampush', 'gliffy', 'jobvite', 'tellapart', 'beyondsoft', 'technologies', 'recruiting',
  'corvisacloud', 'drishticon', 'quardev', 'osi', 'twilio', 'deegit']
  location: 'san francisco'
  filterLocations: ['palo alto', 'oakland', 'sausalito', 'san jose', 'redwood city', 'emeryville',
  'moutain view', 'hayward', 'sunnyvale', 'santa clara', 'san mateo', 'foster city', 'south san francisco']
  days: 3
  nice: ['coffee', 'independent', 'salary', 'generious', 'fun', 'fast', 'catered', 'small', 'beer']
  blacklist: ['8d373576dc21863292893f74b17edfde','9fb7134702ad2a26cc3b2609b87d2d51','821767ca685bf82a7d521f8671321c46']

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

warmQueue = (cb)->
  if not ROOT.WARMING
    maxDirSize = 2.5
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

          ROOT.WARMING = true
          async.series(warmqueue,
          (err, response)->
            ROOT.WARMING = false
            cb(err or response)
          )
        )
      else
        ROOT.WARMING = true
        async.series(warmqueue,
        (err, response)->
          ROOT.WARMING = false
          cb(err or response)
        )
    )

module.exports =
  start: (onReady)->
    warmQueue((response)->
      setInterval(()->
        warmQueue((response)->
          console.info(response)
        )
      , 1000 * 60 * 30)
      onReady()
    )
    
  fetch: (done)->
    fetchQueue(done)