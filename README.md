# about

coin collector is a small HTML5 game built using CoffeeScript where the objective is to uncover as many coins as you can before the timer reaches zero

&copy; 2017, Richard Marks, Stephen Collins, MIT Licensed

# design

the game consists of a 2D board of 10 x 10 tiles

each tile can be one of dirt, a pit, a coin, or a stone covering either dirt, a pit or a coin

at the start, all tiles are the stone tile

when you click on a stone tile, it changes to reveal either dirt, a coin or a pit

if the tile revealed is dirt, you continue playing

if the tile revealed is a pit, you lose a life

if the tile revealed is a coin, you may then click on the coin to collect it, which changes the tile to dirt

you have 3 lives at the start of the game, and gain an extra life for each 25 coins you collect

if you turn over all the tiles in the board, the board is reset to a new random configuration with all tiles turned to stones and you keep playing

the timer counts down each second, starting from 120 seconds on the timer

when the timer reaches zero, the game is over, your total coins are tallied and you get a chance to log a high score which gets stored in local storage
