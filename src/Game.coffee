{Stage} = require './Stage'
{Board} = require './Board'
{Data} = require './Data'
{pascalize} = require './utils'
{UI} = require './UI'
{CountDown} = require './Time'

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
hudFont = new UIFontDef 'sans-serif', 32, 'bold'
hudFill = [
  { position: 0, color: 'white' },
  { position: 1, color: '#E6CC77' }
]
hudStroke = '#85784D'

class Game
  constructor: ->
    @system =
      data: new Data
    @images = {}
    @width = 960
    @height = 540
    @score = 0
    @lives = 3
    @coinsCollectedFromLastPit = 0
    @pauseButton = {}
    @is_gamePaused = false
    @nextClickContinue = false
  # submitScore = ->
  #   @highscores.push @score
  #   @highscores.sort()
  #   @highscores = @highscores[0...10]
  
  preload: (onComplete) ->
    console.warn 'preloading...'
    manifest =
      tileset: 'assets/coin.png'
      grass: 'assets/grass.png'
      pauseButton: 'assets/pause.png'
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
    @board.revealAll()
    # stage needs to redraw on resize
    @stage.onResize = -> @sendMessage redraw, @, @
    # stage resize method needs to have a "this" of the Game instance
    # otherwise the message sending code will fail
    @stage.onResize = @stage.onResize.bind @
    
    @timer = new CountDown { time: 120 }
    @timer.onTick = @onTimerTick.bind @
    @timer.onComplete = @onTimerComplete.bind @
    
    
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
    @timerHUD = new UIText "TIME: #{@timer.time}", font, hudFill, hudStroke
    
    @scoreHUD.textAlign = 'right'
    @scoreHUD.outline = 4
    @scoreHUD.x = (@width * 0.25 | 0) - 16
    @scoreHUD.y = 0
    @scoreHUD.shadowOffsetX = -2
    @scoreHUD.shadowOffsetY = 2
    
    @livesHUD.textAlign = 'left'
    @livesHUD.outline = 4
    @livesHUD.x = (@width * 0.75 | 0) + 16
    @livesHUD.y = 0
    @livesHUD.shadowOffsetX = 2
    @livesHUD.shadowOffsetY = 2
    
    @timerHUD.textAlign = 'center'
    @timerHUD.outline = 4
    @timerHUD.x = @width * 0.5
    @timerHUD.y = @height - (1.2 * @timerHUD.getMeasuredLineHeight())
    @timerHUD.shadowOffsetX = -2
    @timerHUD.shadowOffsetY = -2
    
    # creating pauseButton object here
    @pauseButton.src = assets.pauseButton
    @pauseButton.x = (@width * 0.25 | 0) - 128
    @pauseButton.y = @height * 0.5
    @pauseButton.pause = (ctx,timer, stage, width, height,canvas,onGameClick,is_gamePaused) ->
      ctx.save()
      ctx.fillStyle = 'black'
      ctx.globalAlpha = 0.65
      ctx.fillRect 0, 0, width*stage.scale.x, height*stage.scale.y
      # writing of "click to continue!"
      ctx.font = 'bold 18px sans-serif'
      ctx.fillStyle = 'white'
      ctx.textBaseline = 'center'
      text1 = 'Click to Continue Playing!'
      ctx.fillText(text1,
      canvas.width/ 2-ctx.measureText(text1).width/ 2, canvas.height/ 2)
      timer.pause()
      ctx.restore()
      timer.isPaused = true
    @pauseButton.resume = (ctx,timer,is_gamePaused) ->
      timer.resume()
      @is_gamePaused = is_gamePaused = false
      ctx.restore()

    @updateScore = ->
      @scoreHUD.text = "SCORE: #{@score}"
      @sendMessage redraw, @, @
    @updateLives = ->
      @livesHUD.text = "LIVES: #{@lives}"
      @sendMessage redraw, @, @
    @updateTimer = ->
      @timerHUD.text = "TIME: #{@timer.time}"
      @sendMessage redraw, @, @
    @updateScore = @updateScore.bind @
    @updateLives = @updateLives.bind @
    @updateTimer = @updateTimer.bind @
    @updateScore()
    @updateLives()
    @timer.start true
    
  setupDOM: (assets) ->
    document.title = 'Coin Collector'
    document.body.style.background = "#317830 url('#{assets.grass.src}') repeat"
    
  setupEvents: ->
    clicked = @board.clicked.bind @board
    {pauseButton, ctx, stage, board,timer,width,
    height,canvas,is_gamePaused,nextClickContinue} = @
    size =
      width: stage.canvas.width
      height: stage.canvas.height
    onClick = (mouseEvent) ->
      
      clientRect = stage.canvas.getBoundingClientRect()
      mouseX = mouseEvent.clientX or mouseEvent.x
      mouseY = mouseEvent.clientY or mouseEvent.y
      x = mouseX - clientRect.left
      y = mouseY - clientRect.top
      x = (x / size.width) * stage.width | 0
      y = (y / size.height) * stage.height | 0
      ctx.save()
      ctx.fillStyle = 'pink'
      ctx.fillRect mouseX  * (1/ stage.scale.x),mouseY*(1/ stage.scale.y), 7,7
      ctx.restore()

    onGameClick = (mouseEvent) ->
      # UL = Upper left
      # UR = Upper right
      # LL = Lower left
      # LR = Lower Right

      if is_gamePaused
        pauseButton.resume ctx, timer, is_gamePaused
        ctx.restore()
        is_gamePaused = false
        return

      

      mouseX = mouseEvent.clientX or mouseEvent.x
      mouseY = mouseEvent.clientY or mouseEvent.y

      pauseScaled_UL =
        x: pauseButton.x * stage.scale.x
        y: pauseButton.y * stage.scale.y
      
      pauseScaled_UR =
        x: (pauseButton.x + 50) * stage.scale.x
        y: pauseButton.y * stage.scale.y
      
      pauseScaled_LL =
        x: pauseButton.x * stage.scale.x
        y: (pauseButton.y + 50) * stage.scale.y
      
      pauseScaled_LR =
        x: (pauseButton.x + 50) * stage.scale.x
        y: (pauseButton.y + 50) * stage.scale.y

      console.log "UL -> x: #{pauseScaled_UL.x} y: #{pauseScaled_UL.y}"
      console.log "mouseClick -> x: #{mouseEvent.clientX} y: #{mouseEvent.clientY}"
      console.log "UR -> x: #{pauseScaled_UR.x} y: #{pauseScaled_UR.y}"

      if mouseX >= pauseScaled_LL.x and mouseX <= pauseScaled_UR.x \
      and mouseY >= pauseScaled_UL.y and mouseY <= pauseScaled_LR.y
        console.log 'bing!'
        is_gamePaused = true
        console.log "@is_gamePaused is: #{is_gamePaused}"
        pauseButton.pause(ctx, timer, stage, width, height, canvas)

      response = clicked mouseEvent

    @canvas.addEventListener 'click', onGameClick, false
  
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
  
  onTimerTick: -> @updateTimer()
    
  onTimerComplete: ->
    console.log "timer done"
    # TODO - [rmark] end game session
    

  #
  # our game message handler methods
  #
  
  
  onDraw: (message) ->
    {ctx, canvas, board, grassFillPattern, pauseButton,scoreHUD, livesHUD, timerHUD, stage} = @
    {width, height} = canvas
    
    ctx.save()
    ctx.fillStyle = grassFillPattern
    ctx.fillRect 0, 0, width, height
    
    board.draw ctx
    
    ctx.restore()

    # drawing of blue rectangle drawing code as temporary stand in for pause button
    ctx.save()
    ctx.scale stage.scale.x, stage.scale.y
    ctx.fillStyle = 'blue'
    #ctx.fillRect @pauseButton.x ,  @pauseButton.y, 50, 50
    ctx.drawImage @pauseButton.src, @pauseButton.x, @pauseButton.y, 50, 50
    
    ctx.restore()
    
    ctx.save()
    ctx.scale stage.scale.x, stage.scale.y
    scoreHUD.draw ctx
    ctx.restore()
    
    ctx.save()
    ctx.scale stage.scale.x, stage.scale.y
    livesHUD.draw ctx
    ctx.restore()
    
    ctx.save()
    ctx.scale stage.scale.x, stage.scale.y
    timerHUD.draw ctx
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
    @coinsCollectedFromLastPit += 1
    console.log("@coinsCollectedFromLastPit: #{@coinsCollectedFromLastPit}
    \n@time: #{@timer.time} ")

    # TODO: timer adds 5 seconds if around 117-118
    if @coinsCollectedFromLastPit == 3 and @timer.time < 120
      console.log("more time! add 5 seconds")
      @timer.time += 5
      @coinsCollectedFromLastPit = 0
    @score += POINTS_PER_COIN
    @updateScore()
    if @board.coinsRemaining() <= 0
      @board.revealAllPits()
      {board, timer} = @
      timer.pause()

      resume = ->
        board.reset()
        timer.resume()
      setTimeout resume, 1500
      @sendMessage redraw, @, @
      # TODO - [rmarks] reset the board
      @gameover = true

  onPitFallen: (message) ->
    playAudio 'fall', SFX_CHANNEL
    @sendMessage redraw, @, @
    @lives -= 1
    @updateLives()
    @coinsCollectedFromLastPit = 0

module.exports = Game: Game