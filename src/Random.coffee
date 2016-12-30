# XORShift+ 128-bit Random Number Generator
state = [1, 2]

next = ->
  s0 = state[1]
  state[0] = s0
  s1 = state[0]
  s1 ^= s1 << 23
  s1 ^= s1 >> 17
  s1 ^= s0
  s1 ^= s0 >> 26
  state[1] = s1
  state[0] + state[1]

seed = (n, n2) ->
  state[0] = n or Date.now()
  state[1] = n2 or Date.now() >> 32

rand = (min, max) -> min + (next() % (max - min))

module.exports = rand: rand, seed: seed, state: state