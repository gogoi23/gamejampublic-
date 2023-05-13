extends RigidBody

onready var main = get_node("/root/Main")

signal collected

func _physics_process(_delta):
	if main.paused:
		rotate_y(deg2rad(0)) 
	else:	
		rotate_y(deg2rad(3)) 

func _on_Ammo_body_entered(_body):
	print(_body)
	if _body.is_in_group("enemy"):
		print("Enemy touched ammo box.")
	else:
		queue_free()
		emit_signal("collected")
