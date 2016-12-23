{sinon, expect} = require './testUtil'
{pascalize, camelize} = require '../src/utils'

describe 'utils', ->
  it 'exports correctly', ->
    expect(pascalize).to.exist
    expect(camelize).to.exist
  
  describe 'pascalize', ->
    it 'transforms input to pascal case correctly', ->
      result = pascalize 'foo-bar'
      expect(result).to.equal 'FooBar'
  
  describe 'camelize', ->
    it 'transforms input to camel case correctly', ->
      result = camelize 'foo-bar'
      expect(result).to.equal 'fooBar'
      