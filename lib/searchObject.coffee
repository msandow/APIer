module.exports = (conf) ->
  {
    search: conf.search or []
    days: conf.days or 1
    location: conf.location or ''
    negative: conf.negative or []
  }


