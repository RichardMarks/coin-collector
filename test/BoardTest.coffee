
{sinon, expect} = require './testUtil'

{Board} = require '../src/Board'

# I really don't like importing another class than what is being tested
# but the alternative would be to have the board class provide an api
# that reaches into the Tile class and returns the values
# however, that means more methods to write unit tests for
# so I take the lesser evil and am bringing in the Tile class
{Tile} = require '../src/Tile'
{TILE_WIDTH, TILE_HEIGHT} = Tile.dimensions

describe 'Board', ->
  board = new Board
  it 'exports the class', ->
    expect(Board).not.to.be.undefined

  describe 'constructor', ->
    it 'creates the tiles array', ->
      expect(board.tiles).to.exist
      expect(board.tiles).to.have.lengthOf 100

  describe '#rows', ->
    it 'returns the number of rows of tiles the board contains', ->
      expect(board.rows()).to.equal 10

  describe '#columns', ->
    it 'returns the number of columns of tiles the board contains', ->
      expect(board.columns()).to.equal 10
  
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