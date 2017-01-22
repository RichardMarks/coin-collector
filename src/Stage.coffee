class Stage
  constructor: (@width, @height, parentElement) ->
    canvas = document.createElement 'canvas'
    canvas.width = @width
    canvas.height = @height
    parentElement.appendChild canvas
    
    @canvas = canvas
    @ctx = canvas.getContext '2d'
    @scale = x: 1, y: 1
  
  enableScale: (enabled) ->
    if enabled
      @scaler = @scaleAspectRatio.bind @
      window.addEventListener 'resize', @scaler, false
      @scaler()
    else
      @scaler and window.removeEventListener 'resize', @scaler, false
    
  scaleAspectRatio: ->
    {ctx, canvas, width, height} = @
    # determine orientation
    #@portrait = portrait = canvas.width < canvas.height
    @portrait = window.innerWidth < window.innerHeight #canvas.width < canvas.height
    aspectRatio = window.innerWidth / window.innerHeight
    #console.log "width is: #{window.innerWidth} and height is: #{window.innerHeight}"
    console.log "portait is #{@portrait}"
    if @portrait
      aspectRatio = canvas.height / canvas.width
    inverseAspect = 1.0 / aspectRatio
    
    # set canvas scale
    if @portrait
      console.log "portrait -> aspectRatio: #{aspectRatio} inverseAspect: #{inverseAspect}"
      canvas.height = window.innerHeight
      canvas.width = window.innerHeight * inverseAspect
    else
      console.log "landscape -> aspectRatio: #{aspectRatio} inverseAspect: #{inverseAspect}"
      canvas.width = window.innerWidth
      canvas.height = window.innerWidth * inverseAspect
    
    if canvas.width > window.innerWidth
      canvas.width = window.innerWidth
      
    if canvas.height > window.innerHeight
      canvas.height = window.innerHeight
    
    # set game scale
    scaleX = canvas.width / width
    scaleY = canvas.height / height
    @scale = x: scaleX, y: scaleY
    
    # center canvas
    @center()
    
    # handle user event
    @onResize and @onResize()
    
    ctx.imageSmoothingEnabled = false
    ctx.mozImageSmoothing = false
  
  center: ->
    {canvas, portrait} = @
    if portrait
      top = 0
      left = ((window.innerWidth - canvas.width) * 0.5) | 0
    else
      top = ((window.innerHeight - canvas.height) * 0.5) | 0
      left = 0
    style =
      position: 'absolute'
      top: "#{top}px"
      left: "#{left}px"
    Object.assign canvas.style, style

module.exports = Stage: Stage