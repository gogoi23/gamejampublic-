extends Camera

export (NodePath) var target
onready var player = get_node(target)


func _process(delta : float) -> void:
	translation = Vector3(player.translation.x,40,player.translation.z)
