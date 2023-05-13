extends Control

func _ready():
	Global.hud = self
	load_lives()

func load_lives():
	if Global.lives != 0:
		$HPSystem/HeartsFull.visible = true
		$HPSystem/HeartsEmpty.rect_size.x = Global.max_lives * 53
		$HPSystem/HeartsFull.rect_size.x = Global.lives * 53
	else:
		$HPSystem/HeartsFull.visible = false
