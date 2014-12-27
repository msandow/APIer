module.exports =
  unique: (arr)->
    newarr = []
    hash = {}
    for i in arr
      if not hash[i]
        hash[i] = true
        newarr.push(i)
    
    newarr

  merge: ()->
    newarr = []
    for i in arguments
      if Array.isArray(i)
        for ii in i
          newarr.push(ii)
          
    newarr

  uniqueObjsBy: (arr, key)->
    newarr = []
    hash ={}
    for i in arr
      if not hash[i[key]]
        hash[i[key]] = true
        newarr.push(i)
    
    newarr