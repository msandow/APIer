cheerio = require('cheerio')
request = require('request')
url = require('url')
cache = require('./cache.coffee')
console = require('./console.coffee')

pathFixer = (oh, parsed) ->
  if /^\/\//i.test(oh)
    return parsed.protocol + oh
  if oh isnt '#' and not /^(javascript|http)/i.test(oh)
    return parsed.protocol + '//' + parsed.host + oh
  
  oh

htmlBodyParse = (body, parsed) ->
  $ = cheerio.load(body)

  $('[href]').each((i, el)->
    oh = $(@).attr('href')                  
    $(@).attr('href',pathFixer(oh, parsed))
  )

  $('[src]').each((i, el)->
    oh = $(@).attr('src')                  
    $(@).attr('src',pathFixer(oh, parsed))
  )

  $

module.exports =
  
  respond: (_url, data, cb) ->
    parsed = url.parse(_url)
    response = JSON.parse(data)

    cb(null, 
      responseObj: do () ->
        isHtml = response.headers['content-type'].indexOf('text/html') > -1 or
          response.headers['content-type'].indexOf('text/xml') > -1 or
          response.headers['content-type'].indexOf('+xml') > -1
        return null unless isHtml
        return htmlBodyParse(response.body, parsed) if isHtml 

      statusCode: response.statusCode
      headers: response.headers
    )
  
  make: (_url, _cb) ->
    jar = request.jar()
    self = this

    console.info('Requesting', _url)

    cache.exists(_url, (exists)->
      if exists

        console.info('Cache found for', _url)

        cache.get(_url, (err, data)->
          self.respond(_url, data, _cb)
        )
      else

        console.info('No cache found for', _url)

        request(
          url: _url
          headers:
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:33.0) Gecko/20100101 Firefox/33.0'
            'Connection': 'keep-alive'
            'Accept-Language': 'en-US,en;q=0.5'
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
          method: 'GET'
          gzip: true
          jar: jar
          ,
          (error, response, body) ->
            if error
              _cb(error, null)
              return

            console.info('Writing response to cache', _url, response.statusCode)

            cache.put(_url,
              headers: response.headers,
              statusCode: response.statusCode
              body: body
            , () ->
              self.respond(_url, 
                headers: response.headers,
                statusCode: response.statusCode
                body: body
              , _cb) 
            )
        )
    )
