extends Control

func _physics_process(delta):
	$Spatial.rotate_y(deg2rad(0.5))

func _on_StartButton_pressed():
	SceneTransition.change_scene("res://Main.tscn","fade")



func _on_QuitButton_pressed():
	get_tree().quit()
