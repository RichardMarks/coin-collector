{genUUID} = require './uuid'
{btoa, atob} = window

class Data
  ###
  The Data class is responsible for saving and loading game data to local storage
  in a secure (enough for simple games) format
  ###
  constructor: ->
    ###
    Initializes the internal data storage container
    ###
    @store = window.localStorage
    lastUUID = @store.getItem btoa 'lastUUID'
    if lastUUID
      @uuid = atob lastUUID
    else
      @uuid = genUUID()
      id = btoa 'lastUUID'
      @store.setItem id, btoa @uuid

  write: (pref, value) ->
    ###
    Writes a data value to storage in a secure format
    
        @param {string} pref - the name of the preference
        @param {string} value - the value to write
        
    ###
    uuid = @uuid
    secureItem =
      id: "#{uuid}#{btoa pref}"
      value: btoa value
    @store.setItem secureItem.id, btoa JSON.stringify secureItem

  read: (pref) ->
    ###
    Reads previously written data
    
        @param {string} pref - the name of the preference
        @returns {string} the value or undefined if preference not found
    
    ###
    uuid = @uuid
    id = "#{uuid}#{btoa pref}"
    secureItem = JSON.parse atob @store.getItem id
    atob secureItem.value

module.exports = Data: Data