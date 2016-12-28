{Stage} = require './Stage'
{Board} = require './Board'
{Data} = require './Data'
{pascalize} = require './utils'
{UI} = require './UI'

{UIFontDef, UIText} = UI

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

# yes, this is gaudy - just testing things, we can tweak colorings later
hudFont = new UIFontDef 'monospace', 96, 'bold'
hudFill = 'red'
# [
#   { position: 0, color: 'red' },
#   { position: 1, color: 'yellow' }
# ]
hudStroke = 'orange'

class Game
  constructor: ->
    @system =
      data: new Data
    @images = {}
    @width = 960
    @height = 540
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
    
    @tileset = assets.tileset
    
    # create the Stage instance
    parentElement = document.getElementById 'container'
    @stage = new Stage @width, @height, parentElement
    
    # expose rendering context and canvas from the Stage
    {ctx, canvas} = @stage
    @canvas = canvas
    @ctx = ctx
    @grassFillPattern = ctx.createPattern assets.grass, 'repeat'
    
    # board must be created AFTER the stage
    @board = new Board @
    # stage needs to redraw on resize
    @stage.onResize = -> @sendMessage redraw, @, @
    # stage resize method needs to have a "this" of the Game instance
    # otherwise the message sending code will fail
    @stage.onResize = @stage.onResize.bind @
    
    # this needs to be done BEFORE scaling is enabled
    # otherwise the redraw will try to draw UI items that
    # do not yet exist
    @createUI assets
    
    # scaling has to be enabled AFTER the board is created because
    # the resize method above will get called during enabling the
    # scaling of the stage
    @stage.enableScale true
    
    @setupDOM assets
    
    @setupEvents()
    
    # draw the initial screen
    @sendMessage redraw, @, @
  
  createUI: (assets) ->
    font = "#{hudFont}"
    @scoreHUD = new UIText 'SCORE: 0', font, hudFill, hudStroke
    @livesHUD = new UIText "LIVES: #{@lives}", font, hudFill, hudStroke
    
    # @scoreHUD.textAlign = 'center'
    #@scoreHUD.outline = 4
    @scoreHUD.x = 0 # @width * 0.5 | 0
    @scoreHUD.y = 0 # 16
    
    # @livesHUD.textAlign = 'right'
    #@livesHUD.outline = 4
    @livesHUD.x = @width - 16
    @livesHUD.y = 16
    
    @updateScore = ->
      @scoreHUD.text = "SCORE: #{@score}"
      @sendMessage redraw, @, @
    @updateLives = ->
      @livesHUD.text = "LIVES: #{@lives}"
      @sendMessage redraw, @, @
    @updateScore = @updateScore.bind @
    @updateLives = @updateLives.bind @
    @updateScore()
    @updateLives()
  
  setupDOM: (assets) ->
    document.title = 'Coin Collector'
    document.body.style.background = "#317830 url('#{assets.grass.src}') repeat"
    
    # scoreDiv = document.createElement 'div'
    # livesDiv = document.createElement 'div'
    
    # Object.assign scoreDiv.style, HUD_STYLE
    # Object.assign livesDiv.style, HUD_STYLE
    
    # document.body.appendChild scoreDiv
    # document.body.appendChild livesDiv
    
    # @updateScore = -> scoreDiv.innerText = "SCORE: #{@score}"
    # @updateLives = -> livesDiv.innerText = "LIVES: #{@lives}"
    # @updateScore = @updateScore.bind @
    # @updateLives = @updateLives.bind @
    # @updateScore()
    # @updateLives()
    
  setupEvents: ->
    onClick = @board.clicked.bind @board
    @canvas.addEventListener 'click', onClick, false
  
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
    {ctx, canvas, board, grassFillPattern, scoreHUD, livesHUD, stage} = @
    {width, height} = canvas
    
    ctx.save()
    ctx.fillStyle = grassFillPattern
    ctx.fillRect 0, 0, width, height
    
    board.draw ctx
    
    ctx.restore()
    
    ctx.save()
    # ctx.translate scoreHUD.x, scoreHUD.y
    #ctx.scale stage.scale.x, stage.scale.y
    scoreHUD.draw ctx
    ctx.restore()
    
    ctx.save()
    ctx.translate livesHUD.x, livesHUD.y
    ctx.scale stage.scale.x, stage.scale.y
    livesHUD.draw ctx
    ctx.restore()
    
    
    
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