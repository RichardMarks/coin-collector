{Tile} = require './Tile'
{TILE_WIDTH, TILE_HEIGHT} = Tile.dimensions

BOARD_ROWS = 10
BOARD_COLS = 10
BOARD_SIZE = BOARD_ROWS * BOARD_COLS

BOARD_WIDTH = BOARD_COLS * TILE_WIDTH
BOARD_HEIGHT = BOARD_ROWS * TILE_HEIGHT

getRandomTile = ->
  types = ['dirt', 'coin', 'pit']
  index = Math.random() * types.length
  types[index | 0]

class Board
  @dimensions:
    ROWS: BOARD_ROWS
    COLUMNS: BOARD_COLS
    WIDTH: BOARD_WIDTH
    HEIGHT: BOARD_HEIGHT

  constructor: (@game) ->
    @tiles = []
    tileset = @game.getTileset()
    for row in [0...BOARD_ROWS]
      y = row * TILE_HEIGHT
      for col in [0...BOARD_COLS]
        kind = getRandomTile()
        x = col * TILE_WIDTH
        @tiles.push new Tile x, y, kind, tileset

  reset: ->
    # re-generate a new board
    for tile in tiles
      tile.reset()
      tile.kind = getRandomTile()
    
    # tell the game that it needs to redraw
    message =
      event: 'draw'
    @game.sendMessage message, @, @game
  
  tileAt: (x, y) ->
    @tiles[x + y * BOARD_COLS]
    
  clicked: (mouseEvent) ->
    mouseX = mouseEvent.clientX or mouseEvent.x
    mouseY = mouseEvent.clientY or mouseEvent.y
    column = mouseX / TILE_WIDTH | 0
    row = mouseY / TILE_HEIGHT | 0
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
        
        # TODO [scollins] heck yeah! successfull pit fallen event handler! except add logic
        # if lives = 0
        if tile.kind is 'pit'
          #tile.kind = 'dirt'
          message =
            event: 'pit-fallen'
            payload:
              mouseX: mouseX
              mouseY: mouseY
              row: row
              column: column
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