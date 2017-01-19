{Tile} = require './Tile'
{TILE_WIDTH, TILE_HEIGHT} = Tile.dimensions

BOARD_ROWS = 10
BOARD_COLS = 10
BOARD_SIZE = BOARD_ROWS * BOARD_COLS

BOARD_WIDTH = BOARD_COLS * TILE_WIDTH
BOARD_HEIGHT = BOARD_ROWS * TILE_HEIGHT

getRandomTile = ->
  # types = ['dirt', 'coin', 'pit']
  # right now IF we had an unbiased random number generator we would have an
  # equal distribution of pits, coins, and dirt
  # however, there is a heavy bias in the Math.random RNG which shifts based
  # on the number of times it's called. there is no exact science, you just
  # have to experiment to find a good distribution
  # but one way we can influence the outcome more is by using a larger set
  # of items to choose from with larger or smaller portions of a given kind
  # so to have more dirt, we add more dirt to the types array
  # for more pits, we addmore pit to it
  
  # chance is % of 100 that the chosen tile will be one of the following
  # here I have picked a few different "difficulties" if you will
  # and we can choose which difficulty we want later
  baby =
    dirt: 80
    pit: 1
    coin: 19
  easy =
    dirt: 45
    pit: 15
    coin: 40
  normal =
    dirt: 45
    pit: 35
    coin: 20
  hard =
    dirt: 35
    pit: 35
    coin: 30
  insane =
    dirt: 25
    pit: 65
    coin: 10
  
  chance = normal

  # build up the selection array
  types = []
  for own type, count of chance
    types.push type for i in [0...count]
  
  # pick a random type
  index = Math.random() * types.length
  types[index | 0]

class Board
  @dimensions:
    ROWS: BOARD_ROWS
    COLUMNS: BOARD_COLS
    WIDTH: BOARD_WIDTH
    HEIGHT: BOARD_HEIGHT

  constructor: (@game) ->
    @calculateBoardTransform()
    @generateBoard()

  generateBoard: ->
    @tiles = []
    tileset = @game.getTileset()
    for row in [0...BOARD_ROWS]
      y = row * TILE_HEIGHT
      for col in [0...BOARD_COLS]
        kind = getRandomTile()
        x = col * TILE_WIDTH
        tile = new Tile x, y, kind, tileset
        @tiles.push tile
  
  coinsRemaining: ->
    @tiles.filter (tile) -> tile.kind is 'coin'
    .length
  
  revealAll: ->
    tile.reveal() for tile in @tiles

  revealAllPits: ->
    tile.reveal() for tile in @tiles when tile.kind is 'pit'
  
  calculateBoardTransform: ->
    {game} = @
    
    # we scale the board for effect
    scale =
      x: 1.4 * game.stage.scale.x
      y: 1.4 * game.stage.scale.y

    # we need to center the board in our game canvas
    @offsetX = (game.canvas.width - (scale.x * BOARD_WIDTH)) * 0.5 | 0
    @offsetY = (game.canvas.height - (scale.y * BOARD_HEIGHT)) * 0.5 | 0
    @scale = scale

  draw: (ctx) ->
    @calculateBoardTransform()
    {scale, offsetX, offsetY, tiles} = @
    ctx.save()
    ctx.translate offsetX, offsetY
    ctx.scale scale.x, scale.y
    ctx.fillStyle = 'black'
    ctx.fillRect -4, -4, BOARD_WIDTH + 8, BOARD_HEIGHT + 8
    tile.draw ctx for tile in tiles
    ctx.restore()

  reset: ->
    # re-generate a new board
    for tile in @tiles
      tile.reset()
      tile.kind = getRandomTile()
    
    # tell the game that it needs to redraw
    message =
      event: 'draw'
    @game.sendMessage message, @, @game
  
  tileAt: (x, y) ->
    @tiles[x + y * BOARD_COLS]
  
  getTransformedMouseCoordinates: (mouseX, mouseY) ->
    # we have to re-calculate the board transform now because the
    # stage scaling is applied for each window resize event
    @calculateBoardTransform()
    # because we transform the board we have to
    # transform the mouse coordinates in kind
    {offsetX, offsetY, scale} = @
    tx = (mouseX - offsetX) / scale.x
    ty = (mouseY - offsetY) / scale.y
    # this returns the transformed coordinates as an object
    x: tx, y: ty
  
  invalidClick: (transformedMouseX, transformedMouseY) ->
    # if the mouse is outside the board, the click is invalid
    return true if transformedMouseX < 0 or transformedMouseX > BOARD_WIDTH
    return true if transformedMouseY < 0 or transformedMouseY > BOARD_HEIGHT
    false
  
  clicked: (mouseEvent) ->
    # TODO - [scollins] click event handler has a bug, top left corner of
    # board does not register click event, first clickable square in top left
    # corner redraws the entire board down and to the right, "glitchily"
    # however, the board is "less glitchy" at a window size of 891x427
    mouseX = mouseEvent.clientX or mouseEvent.x
    mouseY = mouseEvent.clientY or mouseEvent.y
    clientRect = @game.canvas.getBoundingClientRect()
    {x, y} = @getTransformedMouseCoordinates mouseX - clientRect.left, mouseY - clientRect.top
    return {x,y} if @invalidClick x, y
    
    column = x / TILE_WIDTH | 0
    row = y / TILE_HEIGHT | 0
    tile = @tileAt column, row
    
    if tile
      if not tile.revealed
        # flip the tile
        tile.reveal()
        # tell the game what was revealed by the click
        payload =
          mouseX: mouseX
          mouseY: mouseY
          row: row
          column: column
          tile: tile.kind
        message =
          event: 'revealed-tile'
          payload: payload
        @game.sendMessage message, @, @game
      else
        # special case for clicking twice on a coin, we collect the coin on second click
        if tile.kind is 'coin'
          tile.kind = 'dirt'
          message =
            event: 'coin-collected'
            payload:
              mouseX: mouseX
              mouseY: mouseY
              row: row
              column: column
          @game.sendMessage message, @, @game
  
module.exports = Board: Board