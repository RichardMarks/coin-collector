Game = require './Game'
boot = ->
  game = new Game()
document.addEventListener 'DOMContentLoaded', boot, false
