core = require('./core.coffee')
obj = require('./../listingObject.coffee')

class careerbuilderParser extends core
  buildListingPageURL: ()->
    @listingURL.replace('{{search}}',@search.search.join('+')).replace('{{location}}',@search.location.replace(/\s/g,'+'))
    .replace('{{negative}}',@search.negative.join(' '))

module.exports = () ->
  new careerbuilderParser(
    listingURL: 'http://www.careerbuilder.com/jobseeker/jobs/jobresults.aspx?sd=2&excrit=freeLoc={{location}};st=a;use=ALL;rawWords={{search}};TID=0;CTY={{location}};SID=CA;CID=US;LOCCID=US;ENR=NO;DTP=DRNS;YDI=YES;IND=ALL;PDQ=All;PDQ=All;PAYL=0;PAYH=gt120;POY=NO;ETD=ALL;RE=ALL;MGT=DC;SUP=DC;FRE=30;CHL=AL;QS=sid_unknown;SS=NO;TITL=0;OB=-relv;JQT=RAD;JDV=False;SITEENT=USJob;MaxLowExp=-1;RecsPerPage=100&sc=3&IPath=JRKV&as:exkw={{negative}}&as:exjl='
    listingParser: (dom)->
      listings = []
      self = this

      dom('tr.prefRow').each(->
        if dom(@).find('.jl_col4').text().indexOf('Relocate') is -1 and dom(@).find('.JobListMidAd').length is 0
          listings.push(new obj(
              dom(@).find('.jl_col2 a.prefTitle').text(),
              dom(@).find('.jl_col3 .prefCompany').text(),
              dom(@).find('.jl_col2 a.prefTitle').attr('href'),
              self.timeParser(dom(@).find('.jl_col5 span[title]').text())
            )
          )
      )

      listings
  )