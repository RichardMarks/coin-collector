{Board} = require './Board'
{Data} = require './Data'
{pascalize} = require './utils'

{WIDTH, HEIGHT} = Board.dimensions
BOARD_WIDTH = WIDTH
BOARD_HEIGHT = HEIGHT

redraw =
  event: 'draw'

POINTS_PER_COIN = 25

class Game
  constructor: ->
    @system =
      data: new Data
    @images = {}
    @score = 0
    @lives = 3
  
  preload: (onComplete) ->
    console.warn 'preloading...'
    manifest =
      tileset: 'assets/coin.png'
      grass: 'assets/grass.png'
    count = (k for k, i of manifest).length
    images = @images
    load = (name, path) ->
      image = new Image
      image.onload = ->
        console.warn "loaded #{name} from #{path}"
        images[name] = image
        count -= 1
        onComplete images if count <= 0
      image.onerror = (err) ->
        console.error(err)
      image.src = path
    load name, path for own name, path of manifest
    
  create: ->
    console.warn 'creating Game'
    @tileset = @images.tileset
    document.title = 'Coin Collector'
    @canvas = document.createElement 'canvas'
    @canvas.width = 960
    @canvas.height = 540
    document.body.insertBefore @canvas, document.body.firstChild
    @ctx = @canvas.getContext '2d'
    
    grass = @ctx.createPattern @images.grass, 'repeat'
    @ctx.fillStyle = grass
    @ctx.fillRect 0, 0, @canvas.width, @canvas.height
    
    # TODO - [rmarks] need to update Game unit test since we moved the board creation to create from the constructor
    @board = new Board @
    @drawBoard @board.tiles, @ctx

    onClick = @board.clicked.bind @board
    @canvas.addEventListener 'click', onClick, false
    
    scoreDiv = document.createElement 'div'
    style =
      backgroundColor: '#204060'
      fontFamily: 'monospace'
      textAlign: 'center'
      fontSize: '48px'
      color: 'white'
      border: '4px solid black'
      boxModel: 'border-box'
      borderRadius: '24px'
    Object.assign scoreDiv.style, style
    document.body.appendChild scoreDiv
    @updateScore = -> scoreDiv.innerText = "SCORE: #{@score}"
    @updateScore = @updateScore.bind @
    @updateScore()
  
  drawBoard: (tiles, ctx) ->
    tile.draw ctx for tile in tiles

  sendMessage: (message, sender, recepient) ->
    if recepient is @
      @handleMessage message
    else
      handler = recepient["on#{pascalize message.event}"].bind recepient
      handler and handler message
  
  handleMessage: (message) ->
    handler = @["on#{pascalize message.event}"].bind @
    handler and handler message
  
  getTileset: -> @tileset
  
  #
  # our game message handler methods
  #
  
  onDraw: (message) ->
    @drawBoard @board.tiles, @ctx
    
  onRevealedTile: (message) ->
    @sendMessage redraw, @, @
    console.log 'todo - handle the action for a tile reveal event'
    actionTable =
      coin: ->
        console.log 'found coin'
      pit: ->
        console.log 'found pit'
      dirt: ->
        console.log 'found dirt'
    
    {tile} = message.payload
    action = actionTable[tile]
    action and action()
  
  onCoinCollected: (message) ->
    @sendMessage redraw, @, @
    # console.log 'todo - handle collecting a coin'
    @score += POINTS_PER_COIN
    @updateScore()

module.exports = Game: Game