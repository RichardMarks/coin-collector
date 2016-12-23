{sinon, expect} = require './testUtil'

{Game} = require '../src/Game'
{Data} = require '../src/Data'
{Board} = require '../src/Board'

describe 'Game', ->
  it 'exports the class', ->
    expect(Game).to.exist
  
  describe 'constructor', ->
    game = new Game
    it 'creates the system data object', ->
      expect(game.system).to.exist
      expect(game.system.data).to.exist
      expect(game.system.data).to.be.an.instanceOf Data
      
    it 'creates the board object', ->
      expect(game.board).to.exist
      expect(game.board).to.be.an.instanceOf Board
  
  describe '#sendMessage', ->
    it 'sends a message to a recepient', ->
      game = new Game
      recepient =
        onTestingSendMessage: (message) ->
          message
      
      testSpy = sinon.spy recepient, 'onTestingSendMessage'
      message =
        event: 'testing-send-message'
      game.sendMessage message, game, recepient
      
      expect(testSpy).to.have.been.calledOnce
      expect(testSpy).to.have.been.calledWithExactly message
      spyCall = testSpy.getCall 0
      expect(spyCall.returnValue).to.deep.equal message
  
  describe '#handleMessage', ->
    it 'passes the message to an associated handler', ->
      game = new Game
      game.onTestingHandleMessage = (message) ->
        message
      testSpy = sinon.spy game, 'onTestingHandleMessage'
      
      message =
        event: 'testing-handle-message'
      game.sendMessage message, @, game
      
      expect(testSpy).to.have.been.calledOnce
      expect(testSpy).to.have.been.calledWithExactly message