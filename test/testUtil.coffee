chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai
expect = chai.expect

TRUE_FALSE = [true, false]

# this is a mock for local storage, since there is no window
# in nodejs. there are many ways to handle the scenario but
# this works for our needs
ls = {}
global.window =
  localStorage:
    setItem: (pref, value) -> ls[pref] = value
    getItem: (pref) -> ls[pref]

  btoa: (s) ->
    buf = new Buffer s
    buf.toString 'base64'

  atob: (s) ->
    buf = new Buffer s, 'base64'
    buf.toString 'ascii'

module.exports =
  TRUE_FALSE: TRUE_FALSE
  chai: chai
  sinon: sinon
  expect: expect