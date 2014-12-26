module.exports =
  unique: (arr)->
    newarr = []
    hash = {}
    for i in arr
      if not hash[i]
        hash[i] = true
        newarr.push(i)
    
    newarr