http = require('http')
url = require('url')
cheerio = require('cheerio')

pathFixer = (oh, parsed) ->
  if /^\/\//i.test(oh)
    return parsed.protocol + oh
  if oh isnt '#' and not /^(javascript|http)/i.test(oh)
    return '******' + parsed.protocol + '//' + parsed.host + oh
  
  oh

module.exports = (_url, _cb) ->
  do (_url, _cb) ->
    parsed = url.parse(_url)
  
    req = http.request(
      host: parsed.host
      path: parsed.path
      method: 'GET'
      port: do () ->
        return parsed.port if parsed.port
        return 80 if parsed.protocol is 'http:'
        return 443 if parsed.protocol is 'https:'
      , (response) ->        
        retData = ''
        
        response.setEncoding('utf8')
        
        response.on('data', (chunk) ->
          retData += chunk
        )
        
        response.on('end', () ->
          _cb(null,
            responseRaw: retData
            responseObj: do () ->
              isHtml = response.headers['content-type'].indexOf('text/html') > -1              
              return null unless isHtml
              
              if isHtml
                $ = cheerio.load(retData)
                
                $('[href]').each((i, el)->
                  oh = $(@).attr('href')                  
                  $(@).attr('href',pathFixer(oh, parsed))
                )
                
                $('[src]').each((i, el)->
                  oh = $(@).attr('src')                  
                  $(@).attr('src',pathFixer(oh, parsed))
                )
                
                return $
            statusCode: response.statusCode
            headers: response.headers
          )
        )
    )
    
    req.on('error', (e) ->
      _cb(e, null)
    )
    
    req.end()
