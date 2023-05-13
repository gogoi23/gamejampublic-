extends Control

signal unpause_game

#quit button exits game
func _on_QuitButton_pressed():
	get_tree().quit()




func _on_ResumeButton_pressed():
	emit_signal("unpause_game")
