Board = require './Board'
Data = require './Data'

class Game
  constructor: ->
    @board = new Board @
    @system =
      data: new Data