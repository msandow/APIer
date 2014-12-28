hapi = require('hapi')
less = require('less')
fs = require('fs')
console = require(__dirname + '/console.coffee')
scraper = require(__dirname + '/../modules/scraper.coffee')
server = new hapi.Server()
server.connection({ port: process.env.PORT or 3000 })
dateFormat = (d)->
  days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
  months = ['January','February','March','April','May','June','July','August','September','October','November','December']
  days[d.getDay()]+', '+months[d.getMonth()]+' '+d.getDate()

server.route(
  method: 'GET',
  path:'/', 
  handler: (request, reply)->
    scraper.fetch((posts)->
      fs.readFile(__dirname + '/../public/index.html', (err, data)->
        html = ''
        for i in posts
          html += '<p style="font-size:'+i.score+'px;"><b><a href="'+i.link+'" target="_blank">'+i.title+'</a></b>&nbsp;&nbsp;&nbsp;&nbsp;('+i.company+')&nbsp;&nbsp;&nbsp;&nbsp;'+dateFormat(i.time)+'&nbsp;&nbsp;&nbsp;&nbsp;'+(if i.company isnt '??' then '<a href="http://www.glassdoor.com/Reviews/'+i.company.replace(/\s/g, '-')+'-reviews-SRCH_KE0,6.htm" target="_blank">Glassdoor</a>' else '')+'&nbsp;&nbsp;&nbsp;&nbsp;<i>'+i.positionHash+'</i></p>'
          html += '<!-- '+(i.content or '')+' -->'
        reply(data.toString().replace(/\{\{content\}\}/gim, html)).type('text/html')
      )
    )
)

server.route(
  method: 'GET',
  path:'/site.css', 
  handler: (request, reply)->
    fs.readFile(__dirname + '/../public/site.less', (err, data)->
      less.render(data.toString(), (e, output)->
        reply(output.css).type('text/css')
      )
    )
)

module.exports = () ->
  scraper.start(()->
    console.info('Server started')
    server.start()
  )