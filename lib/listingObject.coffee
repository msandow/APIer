hash = require('./hash.coffee')

module.exports = (title, company, link, time)->
  link = link or '??'
  company = company or '??'
  time = time or new Date()
  title = title or '??'
  
  {
    title: title
    company: company
    link: link
    time: time
    linkHash: hash(link)
    positionHash: hash(company + title)
    content: false
    score: 0
  }