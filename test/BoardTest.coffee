
{sinon, expect} = require './testUtil'

{Board} = require '../src/Board'

# I really don't like importing another class than what is being tested
# but the alternative would be to have the board class provide an api
# that reaches into the Tile class and returns the values
# however, that means more methods to write unit tests for
# so I take the lesser evil and am bringing in the Tile class
{Tile} = require '../src/Tile'
{TILE_WIDTH, TILE_HEIGHT} = Tile.dimensions


# we have to import Game because Board requires an instance
# of Game to function correctly
{Game} = require '../src/Game'

describe 'Board', ->
  game = new Game
  board = new Board game
  it 'exports the class', ->
    expect(Board).to.exist

  it 'has dimensions', ->
    expect(Board.dimensions).to.exist
    {ROWS,COLUMNS,WIDTH,HEIGHT} = Board.dimensions
    expect(ROWS).to.equal 10
    expect(COLUMNS).to.equal 10
    expect(WIDTH).to.equal 320
    expect(HEIGHT).to.equal 320

  describe 'constructor', ->
    it 'creates the tiles array', ->
      expect(board.tiles).to.exist
      expect(board.tiles).to.have.lengthOf 100

  describe '#clicked', ->
    it 'delegates a mouse click to the respective Tile instance', ->
      column = 4
      row = 5
      mouseEvent =
        clientX: TILE_WIDTH * column
        clientY: TILE_HEIGHT * row
      tile = board.tileAt column, row
      revealSpy = sinon.spy tile, 'reveal'
      board.clicked mouseEvent
      expect(revealSpy).to.have.been.calledOnce