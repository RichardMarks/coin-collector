{Stage} = require './Stage'
{Board} = require './Board'
{Data} = require './Data'
{pascalize} = require './utils'

{WIDTH, HEIGHT} = Board.dimensions
BOARD_WIDTH = WIDTH
BOARD_HEIGHT = HEIGHT

redraw =
  event: 'draw'

POINTS_PER_COIN = 25

SFX_CHANNEL = id: 'sfx', route: 0
BGM_CHANNEL = id: 'bgm', route: 1
playAudio = (sfx, channel) ->
  console.warn "TODO - play audio #{sfx} on channel #{channel.id} with route #{channel.route}"
  # TODO - [rmarks] implement multi-channel sfx playback

HUD_STYLE =
  backgroundColor: '#204060'
  fontFamily: 'monospace'
  textAlign: 'center'
  fontSize: '48px'
  color: 'white'
  border: '4px solid black'
  boxModel: 'border-box'
  borderRadius: '24px'

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
    
  create: (assets) ->
    @width = 960
    @height = 540
    @tileset = assets.tileset
    
    parentElement = document.getElementById 'container'
    @stage = new Stage @width, @height, parentElement
    @stage.onResize = ->
      @sendMessage redraw, @, @
    @stage.onResize = @stage.onResize.bind @
    # TODO - [rmarks] fix scaling
    # @stage.enableScale true
    {ctx, canvas} = @stage
    @canvas = canvas
    @ctx = ctx
    
    document.title = 'Coin Collector'
    document.body.style.background = "#317830 url('#{assets.grass.src}') repeat"
    
    grass = ctx.createPattern assets.grass, 'repeat'
    ctx.fillStyle = grass
    ctx.fillRect 0, 0, canvas.width, canvas.height
    
    @board = new Board @
    @drawBoard @board.tiles, ctx

    onClick = @board.clicked.bind @board
    canvas.addEventListener 'click', onClick, false
    
    scoreDiv = document.createElement 'div'
    Object.assign scoreDiv.style, HUD_STYLE
    document.body.appendChild scoreDiv
    @updateScore = -> scoreDiv.innerText = "SCORE: #{@score}"
    @updateScore = @updateScore.bind @
    @updateScore()
    
    livesDiv = document.createElement 'div'
    Object.assign livesDiv.style, HUD_STYLE
    document.body.appendChild livesDiv
    @updateLives = -> livesDiv.innerText = "LIVES: #{@lives}"
    @updateLives = @updateLives.bind @
    @updateLives()
  
  drawBoard: (tiles, ctx) ->
    {offsetX, offsetY, scale} = @board
    ctx.save()
    ctx.translate offsetX, offsetY
    ctx.scale scale.x, scale.y
    tile.draw ctx for tile in tiles
    ctx.restore()

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
    actionTable =
      dirt: -> playAudio 'whomp', SFX_CHANNEL
      coin: -> playAudio 'bling', SFX_CHANNEL
      pit: ->
        msg =
          event: 'pit-fallen'
        @sendMessage msg, @, @
        
    {tile} = message.payload
    action = actionTable[tile].bind @
    action and action()
  
  onCoinCollected: (message) ->
    playAudio 'chaching', SFX_CHANNEL
    @sendMessage redraw, @, @
    @score += POINTS_PER_COIN
    @updateScore()
    if @board.coinsRemaining() <= 0
      @board.revealAll()
      @sendMessage redraw, @, @
      # TODO - [rmarks] reset the board
      @gameover = true

  onPitFallen: (message) ->
    playAudio 'fall', SFX_CHANNEL
    @sendMessage redraw, @, @
    @lives -= 1
    @updateLives()

module.exports = Game: Game