Tile = require './Tile'

BOARD_ROWS = 10
BOARD_COLS = 10
BOARD_SIZE = BOARD_ROWS * BOARD_COLS

getRandomTile = ->
  types = []
  index = Math.random() * types.length
  types[index | 0]

class Board
  constructor: ->
    # booya!
    @tiles = []
    for row in [0...BOARD_ROWS]
      for col in [0...BOARD_COLS]
        kind = getRandomTile()
        @tiles.push new Tile col, row, kind
        
  rows: -> BOARD_ROWS 
  columns: -> BOARD_COLS
  
module.exports = Board: Board