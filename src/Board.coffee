{Tile} = require './Tile'

BOARD_ROWS = 10
BOARD_COLS = 10
BOARD_SIZE = BOARD_ROWS * BOARD_COLS

{TILE_WIDTH, TILE_HEIGHT} = Tile.dimensions

getRandomTile = ->
  types = []
  index = Math.random() * types.length
  types[index | 0]

class Board
  @dimensions:
    ROWS: BOARD_ROWS
    COLUMNS: BOARD_COLS

  constructor: ->
    # booya!
    @tiles = []
    for row in [0...BOARD_ROWS]
      for col in [0...BOARD_COLS]
        kind = getRandomTile()
        @tiles.push new Tile col, row, kind
        
  rows: -> BOARD_ROWS 
  columns: -> BOARD_COLS
  
  tileAt: (x, y) ->
    @tiles[x + y * BOARD_COLS]
    
  clicked: (mouseEvent) ->
    mouseX = mouseEvent.clientX or mouseEvent.x
    mouseY = mouseEvent.clientY or mouseEvent.y
    column = mouseX / TILE_WIDTH | 0
    row = mouseY / TILE_HEIGHT | 0
    targetTile = @tileAt column, row
    targetTile.reveal()
  
module.exports = Board: Board