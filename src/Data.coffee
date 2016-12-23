{genUUID} = require './uuid'
{btoa, atob} = window

class Data
  constructor: ->
    # todo allocate secure storage and setup a unique identifier
    @store = window.localStorage
    @uuid = genUUID()

  write: (pref, value) ->
    # todo - write pref value to secure storage
    uuid = @uuid
    secureItem =
      id: "#{uuid}#{btoa pref}"
      pref: pref
      value: btoa value
    @store.setItem secureItem.id, JSON.stringify secureItem

  read: (pref) ->
    # todo - read pref from secure storage
    uuid = @uuid
    id = "#{uuid}#{btoa pref}"
    secureItem = JSON.parse @store.getItem id
    atob secureItem.value

module.exports = Data: Data