
class CountDown
  constructor: ({@time = 120, @delay = 1000}) ->
    @onComplete = ->
    @onTick = ->
    @isPaused = false
    @_interval = null
  pause: ->
    if not @isPaused
      clearInterval @_interval
      @isPaused = true
      @_interval = null
  resume: -> 
    if @isPaused
      @isPaused = false
      @start true
  start: (immediate = false) ->
    {delay, onTick, onComplete} = @
    @_interval = null
    tick = ->
      onTick and onTick()
      @time -= 1
      if @time < 0
        clearInterval @_interval
        onComplete and onComplete()
    tick = tick.bind @
    @_interval = setInterval tick, delay
    immediate and tick()

module.exports = CountDown: CountDown

# test = ->
#   timer = new CountDown { time: 10 }
#   timer.onTick = -> console.log "#{timer.time}"
#   timer.onComplete = -> console.log 'BoOm!'
#   timer.start true

# test()
