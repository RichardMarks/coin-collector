chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.use sinonChai
expect = chai.expect

TRUE_FALSE = [true, false]

module.exports =
  TRUE_FALSE: TRUE_FALSE
  chai: chai
  sinon: sinon
  expect: expect