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

  # this is a mock for the btoa and atob methods
  # note that it does not do anything but pass through the input
  # in the browser, the return values would be appropriate. this
  # however lets our tests run correctly
  btoa: (s) -> s
  atob: (s) -> s

module.exports =
  TRUE_FALSE: TRUE_FALSE
  chai: chai
  sinon: sinon
  expect: expect