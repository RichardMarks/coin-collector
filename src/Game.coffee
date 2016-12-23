{Board} = require './Board'
{Data} = require './Data'
{pascalize} = require './utils'

class Game
  constructor: ->
    @board = new Board @
    @system =
      data: new Data
    @images = {}
  
  preload: (onComplete) ->
    manifest =
      tileset: 'assets/coin.png'
    count = (k for k, i of manifest).length
    images = @images
    load = (name, path) ->
      image = new Image
      image.onload = ->
        images[name] = image
        count -= 1
        onComplete images if count <= 0
      image.onerror = (err) ->
        console.error(err)
      image.src = path
    load name, path for own name, path of manifest
    
  create: ->
    @tileset = @images.tileset

  sendMessage: (message, sender, recepient) ->
    if recepient is @
      @handleMessage message
    else
      handler = recepient["on#{pascalize message.event}"]
      handler and handler message
  
  handleMessage: (message) ->
    handler = @["on#{pascalize message.event}"]
    handler and handler message
  
  getTileset: -> @tileset
  
  #
  # our game message handler methods
  #
  
  onDraw: (message) ->
    console.log 'todo - redraw the board to the canvas'
    
  onRevealTile: (message) ->
    console.log 'todo - handle the action for a tile reveal event'

module.exports = Game: Game