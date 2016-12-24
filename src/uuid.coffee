
# constructs unique ids of 25 characters in dash-separated sets of 5 characters each
guid =
  _id: 0
  _parts: [0, 0, 0, 0, 0]
  next: ->
    index = Math.random() * guid._parts.length | 0
    guid._parts[index] += 1
    guid._id = guid._build()
  _build: ->
    id = []
    for part in guid._parts
      id.push(guid._quint part)
    id.join '-'
  _quint: (data) ->
    if data.toString().length < 5
      s = data.toString()
      while s.length < 5
        s = "#{guid._hex()}#{s}"
      s
    else
      data.substr 0, 5
  _hex: ->
    options = '0123456789ABCDEF'
    count = options.length
    index = Math.random * count | 0
    options.charAt index

genUUID = ->
  guid.next()

module.exports = genUUID: genUUID
