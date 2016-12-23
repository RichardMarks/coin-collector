
{sinon, expect} = require './testUtil'

{Board} = require '../src/Board'

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
  
  describe.skip '#clicked', ->
    it 'delegates a mouse click to the respective Tile instance', ->
      # we now need to simulate a mouse event
      # to pass to the clicked method
      # then we need to spy on the target Tile instance
      # and expect that the tile gets the clicked message passed to it
      # in our case, the reveal method should be called
      
      # so first, let's say that we simulate a click on the tile at
      # column = 4, row = 5
      
      # our tile class is going to expose it's width and height
      # it doesn't right now, so we cannot finish this unit test
      # so we can leave it skipped until we have the Tile class working