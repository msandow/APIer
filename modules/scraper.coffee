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
  'drupal', 'netezza', 'teradata', 'django', 'haskell', 'smarty']
  companies: ['android', 'group', 'ascendify', 'ampush', 'zynga', 'mulesoft', 'mindjet', 'imgur', 'mashape',
  'plastiq', 'humble', 'software', 'weebly', 'zipongo',
  'hellosign', '5th finger','lynda','balluun','capital one', 'infoobjects', 'bizlol', 'minted',
  'gliffy', 'corvisacloud', 'drishticon', 'quardev', 'osi', 'twilio', 'deegit', 'moodys', 'ideahelix', 'employment', 
  'macys', 'macy\'s', 'insight global', 'tellapart', 'continuum']
  #'cybercoders', 'accenture', 'technology', 'solutions', 'active soft', 'staffing', 'vircon', 'ziprecruiter', 'ampush', 'jobvite', 'beyondsoft', 'technologies', 'recruiting'
  location: 'san francisco'
  filterLocations: ['palo alto', 'oakland', 'sausalito', 'san jose', 'redwood city', 'emeryville', 'menlo park', 'san carlos',
  'moutain view', 'hayward', 'sunnyvale', 'santa clara', 'san mateo', 'foster city', 'south san francisco', 'burlingame']
  days: 2
  nice: ['coffee', 'independent', 'salary', 'generious', 'fun', 'fast', 'catered', 'small', 'beer', 'node', 'php', 'startup',
  'start-up', 'start up']
  bad: ['angular', 'angularjs', '8+', '8 years', 'agile', 'angular.js', 'advertising', 'symfony']
  blacklist: ['8d373576dc21863292893f74b17edfde','9fb7134702ad2a26cc3b2609b87d2d51','821767ca685bf82a7d521f8671321c46',
  'd5ab900a69016832dbe63c85607aa894', '26875fbfa040f5709eb8a790965b3513','08a274bcdd7bfa44959e7891fb7e2f2d',
  '6ff729deef03696ca676c29eca91a99d', 'bc5c494de8facfa0c07cdc391c397c74', '57251fc9a883f9196de1e1f190f22c6b',
  '81cfc41b7b3fbdf9794fc36b1b9a4bd1', 'c77695820f9679fd1aab468deac9e2f8', 'b5b0363b274ab1c2f41c5bc586ef540c',
  '78ae8ce76dab5f48e38d7f86fa319e90', 'f0e2238feb1cd250401429ff0abb11df', '49ca5b4acccfac004d6e6c5c2a4d5459', '0c65531433d4cd42c50092a1bf2b2808',
  '381cf7091b4810cb117c1a62917a9a78', '5a4bf981b027362afa1d13f671289a3a', '51b3507a2e92d28312988be17aaa9a08', 
  '95089f925e902c47d3a4a770db16f2c7', '9f0119cc666c06d8fe73fd9d9a988604', 'ef51444816437535807311eee370758d']

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