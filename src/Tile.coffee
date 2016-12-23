
# for now, hard-coding the texture data
# later,we can load from json

atlas = {
  dirt: { x: 0, y: 0, width: 32, height: 32 },
  coin: { x: 32, y: 0, width: 32, height: 32 },
  pit: { x: 64, y: 0, width: 32, height: 32 },
  stone: { x: 96, y: 0, width: 32, height: 32 },
  stone_alt: { 128: 0, y: 0, width: 32, height: 32 },
}

class Tile
  constructor: (@x, @y, @kind) ->
    @revealed = false
    @cover = if (@x + @y % 2) then 'stone' else 'stone_alt'
  
  draw: (ctx) ->
    ctx.save()
    if @revealed
      #void ctx.drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight);
      asset = atlas[@kind]
      ctx.drawImage @atlas, asset.x, asset.y, asset.width, asset.height, @x, @y, asset.width, asset.height
    else
      asset = atlas[@cover]
      ctx.drawImage @atlas, asset.x, asset.y, asset.width, asset.height, @x, @y, asset.width, asset.height
    ctx.restore()
  
  reveal: -> @revealed = true
  reset: -> @revealed = false

module.exports = Tile