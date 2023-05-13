# Player.gd
# Version: 10/8/2022
extends KinematicBody

#signals
signal dead

#variables
export var mouse_sensitivity = 0.15
export var speed = 10.0
export var direction = Vector3()
export var h_acceleration = 6.0
export var air_acceleration = 1.0
export var normal_acceleration = 6.0
export var h_velocity = Vector3()
export var movement = Vector3()
export var jump_impulse = 10.0
export var gravity = 20
var gravity_vector = Vector3()
var full_contact = false

var shoot = false
var aim = false
var gun_ammo = 30
var gun_clip_capacity = 30
var gun_clip = gun_clip_capacity
var reloadTime = 3

var game_started = false

var ammo_count = gun_ammo + gun_clip
var paused = false
var vulnerable = true


export var num_keys = 0

onready var head = $Head
onready var ground_check = $GroundCheck
onready var ray_cast = $Head/Camera/RayCast
onready var bulletHole = preload("res://bulletImpact.tscn")

var max_speed = 15.0
var min_speed = 1.0
var max_stamina = 100
var stamina = max_stamina


# readies game
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$reloadTimer.wait_time = 3
	$Head/Camera/gun.rotate_z(0)
	

#takes keyboard and mouse input
func _input(event):
	if Input.is_action_just_pressed("mouse_escape"):
		paused = true
		print(paused)
	if event is InputEventMouseMotion and paused == false:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _physics_process(delta):
	#print($Head/Camera/HUD.ammo)
	if game_started and not paused and Global.lives > 0:
		ammo_count = gun_ammo + gun_clip
		$Head/Camera/HUD.updateAmmo(gun_ammo,gun_clip,gun_clip_capacity)
		if Input.is_action_pressed("aim"):
		  $Head/Camera/gunAimed.visible = true
		  $Head/Camera/gun.visible = false
		  $Head/Camera/crosshair.visible = false
		else:
		  $Head/Camera/crosshair.visible = true
		  $Head/Camera/gunAimed.visible = false
		  $Head/Camera/gun.visible = true

		if Input.is_action_just_pressed("reload"):
		  print("reload started")
		  if gun_ammo>0:
			  $reloadTimer.start()
			  $Head/Camera/gun/reload.play()
			  $AnimationPlayer.play("reload")
		  else:
			  $Head/Camera/HUD.displayNoBullets()
			  $Head/Camera/gun/emptyReload.play()

		$Head/Camera/HUD/AmmoCount.text = "Ammo: %s" % ammo_count
		#speed = range_lerp(ammo_count, 100, 1, 1, 10)
		if ammo_count > 0:
			speed = min_speed + (14.0 / (ammo_count / 45.0))
		else:
			speed = max_speed


		if speed > max_speed:
			speed = max_speed
		
		if Input.is_action_pressed("sprint"):
			if int(stamina) > 0:
				speed *= 2
				stamina -= 5 * delta
				$Head/Camera/HUD.updateStamina(stamina)
				$Head/Camera/HUD/OutOfStamina.hide()
#				yield(get_tree().create_timer(0.5), "timeout")
			else:
				$Head/Camera/HUD/OutOfStamina.show()
		
		elif stamina != max_stamina:
			stamina += 5 * delta
			$Head/Camera/HUD.updateStamina(stamina)
		

		if Input.is_action_pressed("click") and not shoot:
			if gun_clip > 0:
				shoot = true
				$shootTimer.start()
				if Input.is_action_pressed("aim"):
					$AnimationPlayer.play("shootReload")
				else:
					$AnimationPlayer.play("shoot")
				$flameTimer.start()
				$Head/Camera/gun/flash.visible = true
				
				gun_clip =  gun_clip -1;
				var bulletPath = $Head/Camera/RayCast
				#print("Player has attacked.")
				
				
				if bulletPath.is_colliding():
					var target = bulletPath.get_collider() 
					print(target)
					if target.is_in_group("players"):
						print("Player shot himself")
					else:	
						var b = bulletHole.instance()
						bulletPath.get_collider().add_child(b)
						b.global_transform.origin = bulletPath.get_collision_point()
						b.look_at(bulletPath.get_collision_point()+bulletPath.get_collision_normal(),Vector3.UP)
					
					
					if target != null and target.is_in_group("enemy"):
						$hit_sound.play()
						$Head/Camera/hitmarker.visible = true
						target.loseHealth(50)
				$Head/Camera/gun/gunshot.play()
			else:
				$Head/Camera/gun/emptygunshot.play()

		direction = Vector3()
		
		if Input.is_action_pressed("detectivemode"):
			var obs = get_tree().get_nodes_in_group("detectivemode")
			for object in obs:
				object.visible = false
		
		else:
			var obs = get_tree().get_nodes_in_group("detectivemode")
			for object in obs:
				object.visible = true
		
		if Input.is_action_pressed("move_forward"):
			direction -= transform.basis.z
		if Input.is_action_pressed("move_backward"):
			direction += transform.basis.z
		if Input.is_action_pressed("move_left"):
			direction -= transform.basis.x
		if Input.is_action_pressed("move_right"):
			direction += transform.basis.x
		
		if ground_check.is_colliding():
			full_contact = true
		else:
			full_contact = false

		if not is_on_floor():
			gravity_vector += Vector3.DOWN * gravity * delta
			h_acceleration = air_acceleration
		elif is_on_floor() and full_contact:
			gravity_vector = - get_floor_normal() * gravity
			h_acceleration = normal_acceleration 
		else:
			gravity_vector = -get_floor_normal()
			h_acceleration = normal_acceleration
		
		if (is_on_floor() or ground_check.is_colliding()) and Input.is_action_pressed("jump"):
			gravity_vector = Vector3.UP * jump_impulse 
			
		direction = direction.normalized()
		h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
		movement.z = h_velocity.z + gravity_vector.z
		movement.x = h_velocity.x + gravity_vector.x
		movement.y = gravity_vector.y
			
		move_and_slide(movement, Vector3.UP)

func _on_reloadTimer_timeout():
	print("Reload done.")
	var amount_needed = gun_clip_capacity - gun_clip
	if (amount_needed > gun_ammo):
		amount_needed = gun_ammo 
	gun_clip = gun_clip + amount_needed
	gun_ammo = gun_ammo - amount_needed
	$reloadTimer.stop()

func _on_flameTimer_timeout():
	$Head/Camera/gun/flash.visible = false
	if($Head/Camera/hitmarker.visible ):
		$Head/Camera/hitmarker.visible = false
	$flameTimer.stop()

func _on_Ammo_collected():
	$pickupAmmoSound.play()
	print("collected")
	gun_ammo += 30

func _on_MobDetector_body_entered(body):
	#print("entered")
	if "Enemy" in body.name and game_started and vulnerable:
		print(vulnerable)
		Global.lose_life()
		vulnerable = false
		if Global.lives == 0:
			emit_signal("dead")
		yield(get_tree().create_timer(2.0), "timeout")
		vulnerable = true
		print(vulnerable)
		


func _on_shootTimer_timeout():
	shoot = false
	$shootTimer.start()
