
class CountDown
  constructor: ({@time = 120, @delay = 1000}) ->
    @onComplete = ->
    @onTick = ->
  start: (immediate = false) ->
    {delay, onTick, onComplete} = @
    interval = null
    tick = ->
      onTick and onTick()
      @time -= 1
      if @time < 0
        clearInterval interval
        onComplete and onComplete()
    tick = tick.bind @
    interval = setInterval tick, delay
    immediate and tick()

module.exports = CountDown: CountDown

# test = ->
#   timer = new CountDown { time: 10 }
#   timer.onTick = -> console.log "#{timer.time}"
#   timer.onComplete = -> console.log 'BoOm!'
#   timer.start true

# test()