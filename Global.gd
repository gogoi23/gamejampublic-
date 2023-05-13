extends Node

var max_lives = 4
var lives = max_lives
var hud

# Taking damage.
func lose_life():
	lives -= 1
	hud.load_lives()
