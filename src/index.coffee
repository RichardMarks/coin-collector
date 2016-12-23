Game = require './Game'
boot = ->
  ###
  boots the game when the `DOMContentLoaded` browser event fires
  ###
  game = new Game()
document.addEventListener 'DOMContentLoaded', boot, false
