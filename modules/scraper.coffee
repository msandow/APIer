async = require('async')
util = require(__dirname + '/../lib/utilities.coffee')
fs = require('fs')
console = require(__dirname + '/../lib/console.coffee')

process.env.TZ = 'America/Los_Angeles'

ROOT = exports ? this
ROOT.WARMING = false

search =
  search: ['jquery']
  negative: ['.net', 'salesforce', 'junior', 'wordpress', 'j2ee', 'manager', 'perl', 'evangelist',
  'dba', 'consultant', 'plm', 'cq', 'admin', 'analyst', 'contract', 'intern', 'jsp', 'recruiting', 'informatica', 'asp.net',
  'drupal', 'netezza', 'teradata', 'django', 'haskell', 'smarty', 'designer', 'opencl', 'unity', 'sharepoint', 'client', 'partner',
  'cybercoders']
  companies: ['android', 'group', 'ascendify', 'ampush', 'zynga', 'mulesoft', 'mindjet', 'imgur', 'mashape',
  'plastiq', 'humble', 'software', 'weebly', 'zipongo',
  'hellosign', '5th finger','lynda','balluun','capital one', 'infoobjects', 'bizlol', 'minted',
  'gliffy', 'corvisacloud', 'drishticon', 'quardev', 'osi', 'twilio', 'deegit', 'moodys', 'ideahelix', 'employment', 
  'macys', 'macy\'s', 'insight global', 'tellapart', 'continuum', 'tokbox', 'peanut labs', 'buffer', 'celtra', 'opentable',
  'stumbleupon', 'switch communications', 'resources', 'techfetch',
  'cybercoders', 'accenture', 'technology', 'solutions', 'active soft', 'staffing', 'vircon', 'ziprecruiter', 'ampush', 'jobvite', 'beyondsoft', 'technologies', 'recruiting', 'diverse lynx',
  'info\. objects', 'revolution global', 'mtnview', 'mtvtech', 'robert half', 'fild', 'netsource', 'damcosoft', 'damco', 'apple',
  'VisionIT', 'Techsophy', 'Mahindra', 'Zentek', 'Intelliswift', 'k-tek', 'tekvalley', 'gdh consulting', 'autodesk', 'hire', 'CompNova', 'CyberSearch',
  'oracle', 'zealtech', 'eitacies', 'scrumlink', 'consulting', 'trinamix', 'associates', 'roblox', 'xperttech', 'vertisystem',
  'nextstepsystems', 'Ginas Tech Jobs', 'parallelpartners', 'parallel partners', 'systematics agency',
  'plangrid', 'hall', 'research now', 'adobe', 'expensify', 'leap motion', 'placeiq', 'answers', 'box', 'elasticsearch',
  'roche', 'polyvore', 'casetext', 'shoprunner', 'clover', 'citrix', 'walmart', 'it first source', 'akraya', 'it-scient',
  'volt', 'coupons', 'paypal', 'pds tech', 'kelly services']
  #
  location: 'san francisco'
  filterLocations: ['redwood', 'san ramon', 'dublin', 'Emeryville', 'fremont', 'san francisco']
  days: 1
  nice: ['coffee', 'independent', 'salary', 'generious', 'fun', 'fast', 'catered', 'small', 'beer', 'node', 'php', 'startup',
  'start-up', 'start up', 'travel', 'europe', 'mithril']
  bad: ['angular', 'angularjs', '8+', '8 years', 'agile', 'angular.js', 'advertising', 'symfony', 'CS fundamentals', 'education',
  'marketing', 'a/b testing', 'san francisco', 'offshore', 'india', '6 month', 'dojo', 'd3']
  blacklist: []
  filterTitles: ['assistant', 'scientist', 'marketing', 'java ', 'java)', 'mobile', 'performance', 'quality', 'director', 'android', 'ios', 'c++', 'flash', 'aggregation' ,'test',
  'automation', 'network', 'administrator', 'virtual', 'QA', 'associate', 'principal', 'devops', 'python', 'rails', 'meteor',
  'support', 'angular', 'angularjs', 'backend', 'sales', 'accountant', 'game']

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