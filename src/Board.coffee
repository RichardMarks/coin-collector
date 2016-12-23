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
      for col in [0...BOARD_COLS]
        kind = getRandomTile()
        @tiles.push new Tile col, row, kind, tileset

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
  
module.exports = Board: Board