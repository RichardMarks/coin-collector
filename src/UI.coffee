DEFAULT_FONT_FACE = 'monospace'
DEFAULT_FONT_SIZE = 24
DEFAULT_FONT_STYLE = 'normal'

class UIFontDef
  constructor: (@face = DEFAULT_FONT_FACE, @size = DEFAULT_FONT_SIZE, @style = DEFAULT_FONT_STYLE) ->
    if @style isnt DEFAULT_FONT_STYLE
      @style = "#{@style} "
    else
      # minor optimization for normal style,
      # it's implicit so no need to allocate more string space
      @style = ''
  toString: -> "#{@style}#{@size}px #{@face}"

textCanvas = document.createElement 'canvas'
textCanvas.width = 1
textCanvas.height = 1
textContext = textCanvas.getContext '2d'

DEFAULT_FONT = "#{new UIFontDef}"
DEFAULT_TEXT_ALIGNMENT = 'left'
DEFAULT_TEXT_BASELINE = 'top'

OFFSCREEN = -65535
class UIText
  constructor: (@text, @font, fill, stroke) ->
    @setFillStyle fill
    @setStrokeStyle stroke
    @priorX = OFFSCREEN
    @priorY = OFFSCREEN
    @x = 0
    @y = 0
    @outline = 0
    @textAlign = DEFAULT_TEXT_ALIGNMENT
    @textBaseline = DEFAULT_TEXT_BASELINE
    @shadowColor = 'black'
    @shadowBlur = 0
    @shadowOffsetX = 0
    @shadowOffsetY = 0
  
  setFillStyle: (fill) ->
    @gradientFill = false
    @fillStyle = fill
    isArray = Array.isArray fill
    if isArray and fill.length >= 1
      if fill.length is 1
        @fillStyle = fill[0].color
      else
        @fillStyle = fill.slice()
        @gradientFill = true
  
  setStrokeStyle: (stroke) ->
    @gradientStroke = false
    @strokeStyle = stroke
    isArray = Array.isArray stroke
    if isArray and stroke.length >= 1
      if stroke.length is 1
        @strokeStyle = stroke[0].color
      else
        @strokeStyle = stroke.slice()
        @gradientStroke = true
  
  applyFillStyle: (ctx) ->
    style = @fillStyle or 'white'
    if @gradientFill
      x1 = x2 = @x
      y1 = @y
      y2 = y1 + @getMeasuredLineHeight()
      gradient = ctx.createLinearGradient x1, y1, x2, y2
      gradient.addColorStop stop.position, stop.color for stop in style
      ctx.fillStyle = gradient
    else
      ctx.fillStyle = style
    @cacheFillStyle = ctx.fillStyle
  
  applyStrokeStyle: (ctx) ->
    style = @strokeStyle or 'black'
    if @gradientStroke
      x1 = x2 = @x
      y1 = @y
      y2 = y1 + @getMeasuredLineHeight()
      gradient = ctx.createLinearGradient x1, y1, x2, y2
      gradient.addColorStop stop.position, stop.color for stop in style
      ctx.strokeStyle = gradient
    else
      ctx.strokeStyle = style
    @cacheStrokeStyle = ctx.strokeStyle
  
  draw: (ctx) ->
    {x, y, priorX, priorY, outline} = @
    if x isnt priorX or y isnt priorY
      @priorX = @x
      @priorY = @y
      @applyFillStyle ctx
      @applyStrokeStyle ctx
    
    if outline
      ctx.lineWidth = 1.0 * outline
      ctx.miterLimit = 0
      ctx.lineJoin = 'bevel'
    @drawText @prep ctx
  
  drawTextLine: (ctx, text, y) ->
    w = @maxWidth or 0xFFFF
    tx = @x
    ty = @y + y
    if @outline
      ctx.strokeText text, tx, ty, w
    ctx.fillText text, tx, ty, w
  
  prep: (ctx) ->
    ctx.font = @font or DEFAULT_FONT
    ctx.textAlign = @textAlign or DEFAULT_TEXT_ALIGNMENT
    ctx.textBaseline = @textBaseline or DEFAULT_TEXT_BASELINE
    ctx.fillStyle = @cacheFillStyle
    ctx.strokeStyle = @cacheStrokeStyle
    ctx.shadowColor = @shadowColor
    ctx.shadowBlur = @shadowBlur
    ctx.shadowOffsetX = @shadowOffsetX
    ctx.shadowOffsetY = @shadowOffsetY
    ctx
    
  drawText: (ctx) ->
    lineHeight = @lineHeight or @getMeasuredLineHeight()
    count = 0
    hardLines = "#{@text}".split /(?:\r\n|\r|\n)/
    for str in hardLines
      @drawTextLine ctx, str, count * lineHeight
      count += 1

  getMeasuredLineHeight: -> 1.2 * @getMeasuredWidth 'M'
  
  getMeasuredWidth: (text) ->
    textContext.save()
    width = @prep(textContext).measureText(text).width
    textContext.restore()
    width
    
UI =
  UIFontDef: UIFontDef
  UIText: UIText

module.exports = UI: UI