{Game} = require './Game'
boot = ->
  ###
  boots the game when the `DOMContentLoaded` browser event fires
  ###
  game = new Game()
  onPreload = (images) ->
    game.create()
  game.preload onPreload
document.addEventListener 'DOMContentLoaded', boot, false
