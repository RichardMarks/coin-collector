{Game} = require './Game'
boot = ->
  ###
  #boots the game when the `DOMContentLoaded` browser event fires
  ####
  game = new Game()
  onPreload = (assets) ->
    game.create assets
  game.preload onPreload
document.addEventListener 'DOMContentLoaded', boot, false
