extends KinematicBody

signal shot
export var min_speed = 5.0
export var max_speed = 5.0
var health = 150
var max_health
var gravity = 9.8
onready var player = get_node("/root/Main/Player")
onready var main = get_node("/root/Main")

signal dead()

var velocity = Vector3.ZERO
var fall_speed = Vector3.ZERO

#automatically moves the snowman at random velocities
func _physics_process(delta):
	if not main.paused:
		velocity = ((player.translation - translation).normalized()) * 8.0
		look_at(player.translation, Vector3.UP)
		rotation.x = 0
		rotation.z = 0
		rotate_y(PI / 2)
		move_and_slide(velocity)
		fall_speed.y -= gravity * delta
		move_and_slide(fall_speed)
	else:
		velocity = Vector3.ZERO

#initializes enemy
func initialize(start_position, _player_position):
	translation = start_position
	look_at(player.translation, Vector3.UP)
	rotate_y(2.3)
	max_health = health
	var speed = rand_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * speed
	velocity.y = 0
	velocity = velocity.rotated(Vector3.UP, rotation.y)

func loseHealth(damage):
	health-=damage
	if health <= 0:
		die()

func die():
	emit_signal("dead")
	queue_free()
