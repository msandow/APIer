cheerio = require('cheerio')
request = require('request')
url = require('url')

pathFixer = (oh, parsed) ->
  if /^\/\//i.test(oh)
    return parsed.protocol + oh
  if oh isnt '#' and not /^(javascript|http)/i.test(oh)
    return '******' + parsed.protocol + '//' + parsed.host + oh
  
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

module.exports = (_url, _cb) ->
  jar = request.jar()
  parsed = url.parse(_url)

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
        
      _cb(null, 
        responseObj: do () ->
          isHtml = response.headers['content-type'].indexOf('text/html') > -1              
          return null unless isHtml
          return htmlBodyParse(body, parsed) if isHtml 
            
        statusCode: response.statusCode
        headers: response.headers
      )
  )
