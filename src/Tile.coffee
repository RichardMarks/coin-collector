
# for now, hard-coding the texture data
# later,we can load from json
atlas =
  dirt: 
    x: 0, y: 0, width: 32, height: 32
  coin:
    x: 32, y: 0, width: 32, height: 32
  pit:
    x: 64, y: 0, width: 32, height: 32
  stone:
    x: 96, y: 0, width: 32, height: 32
  stone_alt:
    x: 128, y: 0, width: 32, height: 32

class Tile
  @dimensions:
    TILE_WIDTH: 32
    TILE_HEIGHT: 32

  constructor: (@x, @y, @kind) ->
    @revealed = false
    @cover = if (@x + @y % 2) then 'stone' else 'stone_alt'
  
  draw: (ctx) ->
    ctx.save()
    asset = @_getAsset()
    ctx.drawImage @image, asset.x, asset.y, asset.width, asset.height, @x, @y, asset.width, asset.height
    ctx.restore()
  
  reveal: -> @revealed = true
  reset: -> @revealed = false

  _getAsset: ->
    if @revealed
      atlas[@kind]
    else
      atlas[@cover]
  
module.exports = Tile: Tile, atlas: atlas