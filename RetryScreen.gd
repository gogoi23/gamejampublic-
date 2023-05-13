extends Control




func _on_RetryButton_pressed():
	SceneTransition.change_scene("res://Main.tscn","fade")


func _on_MenuButton_pressed():
	SceneTransition.change_scene("res://StartScreen.tscn","fade")
