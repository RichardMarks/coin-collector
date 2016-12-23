{sinon, expect} = require './testUtil'

{Data} = require '../src/Data'

describe 'Data', ->
  data = new Data
  store = data.store
  it 'exports the class', ->
    expect(Data).to.exist

  describe 'constructor', ->
    it 'sets the store', ->
      expect(store).to.exist

    it 'sets a unique identifier', ->
      expect(data.uuid).to.exist
    
    it 'reloads last uuid', ->
      nextData = new Data
      expect(data.uuid).to.deep.equal nextData.uuid

  describe '#write', ->
    it 'should write a value to storage', ->
      setSpy = sinon.spy store, 'setItem'
      data.write 'pref', 'value'
      expect(setSpy).to.have.been.calledOnce

  describe '#read', ->
    it 'should read a stored value from storage', ->
      getSpy = sinon.spy store, 'getItem'
      data.write 'pref', 'value'
      value = data.read 'pref'
      expect(getSpy).to.have.been.calledOnce
      expect(value).to.equal('value')