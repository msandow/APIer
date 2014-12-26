require('coffee-script/register')
require('mocha')
fs = require('fs')
expect = require('chai').expect
mapper = require(__dirname+'/../lib/mapper.coffee')
request = require(__dirname+'/../lib/request.coffee')
ut = require(__dirname+'/../lib/utilities.coffee')

getMockFile = (cb) ->
  fs.readFile(__dirname+'/mock', (err, data)->
    request.respond('http://sfbay.craigslist.org/search/sss', data.toString(), cb)
  )

describe('Mapper', ->

  describe('Array Map', ->
    
    it('Should get all title', (done)->
      getMockFile((err, data)->
        mapper.query('d.val=arrayOf(".rightpane .row[data-pid]",(->{text: @find(".pl a").text()}))', data.responseObj, (resp)->
          expect(resp.length).to.equal(100)
          expect(resp.every((i)->
            i.text and i.text.length > 1
          )).to.equal(true)
          done()
        )
      )
    )
    
    it('Should get buttons', (done)->
      getMockFile((err, data)->
        mapper.query('d.val=arrayOf(".buttongroup a",(->@attr("href")))', data.responseObj, (resp)->
          resp = ut.unique(resp)
          
          expect(resp.length).to.equal(13)
          expect(resp.every((i)->
            /http:\/\//.test(i)
          )).to.equal(true)
          done()
        )
      )
    )
    
    it('Should get range', (done)->
      getMockFile((err, data)->
        mapper.query('d.val=arrayOf(range("span.pl a",0,1),(->@attr("href")))', data.responseObj, (resp)->
          expect(resp.length).to.equal(1)
          expect(resp[0]).to.equal('http://sfbay.craigslist.org/eby/msg/4780831322.html')
          done()
        )
      )
    )
  )
)