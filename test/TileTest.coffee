{sinon, expect} = require './testUtil'

{Tile, atlas} = require '../src/Tile'

describe 'Tile', ->
  it 'exports the class', ->
    expect(Tile).to.exist

  it 'exports the atlas data', ->
    expect(atlas).to.exist
  
  describe 'constructor', ->
    it 'chooses an alternate covering based on position', ->
      tile = new Tile 0, 0, 'dirt'
      expect(tile.cover).to.equal 'stone_alt'
      tile2 = new Tile 0, 1, 'dirt'
      expect(tile2.cover).to.equal 'stone'
      tile3 = new Tile 1, 1, 'dirt'
      expect(tile2.cover).to.equal 'stone'
    
    it 'starts covered', ->
      tile = new Tile 0, 0, 'dirt'
      expect(tile.revealed).to.be.false
    
    it 'assigns the x, y, and kind properties', ->
      x = 10
      y = 20
      kind = 'pit'
      tile = new Tile x, y, kind
      expect(tile).to.have.property('x').that.deep.equals x
      expect(tile).to.have.property('y').that.deep.equals y
      expect(tile).to.have.property('kind').that.deep.equals kind
  
  describe '#reveal', ->
    it 'should reveal the kind of tile', ->
      tile = new Tile 0, 0, 'pit'
      expect(tile.revealed).to.be.false
      tile.reveal()
      expect(tile.revealed).to.be.true
  
  describe '#reset', ->
    it 'should hide the kind of tile', ->
      tile = new Tile 0, 0, 'pit'
      expect(tile.revealed).to.be.false
      tile.reveal()
      expect(tile.revealed).to.be.true
      tile.reset()
      expect(tile.revealed).to.be.false
  
  describe '#draw', ->
    it 'should draw the appropriate asset', ->
      tile = new Tile 0, 0, 'pit'
      image =
        id: 'pit'
      # this is something that the board should be responsible for
      tile.image = image
      stone_alt =
        x: 128, y: 0, width: 32, height: 32
      pit =
        x: 64, y: 0, width: 32, height: 32
      ctx =
        save: ->
        restore: ->
        drawImage: (img, sx, sy, sw, sh, dx, dy, dw, dh) ->
      drawImageSpy = sinon.spy ctx, 'drawImage'
      tile.reveal()
      tile.draw ctx
      expect(drawImageSpy).to.have.been.calledOnce
      expect(drawImageSpy).to.have.been.calledWithExactly image, pit.x, pit.y, pit.width, pit.height, 0, 0, pit.width, pit.height
      tile.reset()
      tile.draw ctx
      expect(drawImageSpy).to.have.been.calledTwice
      expect(drawImageSpy.getCall(1)).to.have.been.calledWithExactly image, stone_alt.x, stone_alt.y, stone_alt.width, stone_alt.height, 0, 0, stone_alt.width, stone_alt.height