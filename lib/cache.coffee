fs = require('fs')
hash = require('./hash.coffee')
CACHE_DIR = __dirname + '/__cache/'

module.exports =
  exists: (str, cb) ->
    fs.exists(CACHE_DIR, (exists)->
      if exists
        fs.exists(CACHE_DIR + hash(str), (exists)->
          cb(exists)
        )
      else
        fs.mkdir(CACHE_DIR, ()->
          cb(false)
        )
    )  

  put: (str, val, cb) ->
    val = JSON.stringify(val) if typeof val is 'object'

    fs.writeFile(CACHE_DIR + hash(str), val, ()->
      cb()
    )

  get: (str, cb) ->
    fs.readFile(CACHE_DIR + hash(str), (err, data)->
      cb(err, data.toString())
    )
    
  clear: (str, cb) ->
    @exists(str, (exists)->
      if exists
        fs.unlink(CACHE_DIR + hash(str), ()->
          cb()
        )
      else
        cb()
    )