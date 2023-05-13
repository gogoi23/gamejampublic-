# Main.gd
# controls main game behavior

extends Node

export (PackedScene) var ammo_scene     = preload("res://Ammo.tscn")
export (PackedScene) var wall_scene     = preload("Wall.tscn")
export (PackedScene) var building_scene = preload("Building.tscn")
export (PackedScene) var tree_scene     = preload("Tree.tscn")
export (PackedScene) var tunnel_scene   = preload("Tunnel.tscn")
export (PackedScene) var ramp_scene     = preload("Ramp.tscn")
export (PackedScene) var enemy_scene    = preload("Enemy.tscn")

var wave = 0
var mob_count = 0
onready var main = self
onready var wave_label = $Player/Head/Camera/UserInterface/WaveLabel
var paused = false

signal pause_game
signal unpause_game

func _ready():
	$MobTimer.autostart = false
	randomize()
	generate_walls()
	generate_buildings()
	generate_trees()
	generate_tunnels()
	generate_ramps()

	$CSGCombiner.show()
	#spawn_ammo()
	generate_walls()
	Global.lives = Global.max_lives
	$Player/Head/Camera/UserInterface.load_lives()
	$Player.show()
	$Player.game_started = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#$MobTimer.start()

func _physics_process(_delta):
	if Input.is_action_just_pressed("mouse_escape") and paused == false and $Player.game_started == true:
		emit_signal("pause_game")
	elif Input.is_action_just_pressed("mouse_escape") and paused == true and $Player.game_started == true:
		emit_signal("unpause_game")

func generate_walls():
	
	# number of walls
	var num_walls = 40
	
	# wall generation
	for i in num_walls:
		var wall = wall_scene.instance()
		add_child(wall)
		wall.set_use_collision(true)
		
		# location
		wall.translation.x = (randi() % 200) - 100.0 # -100 - 99
		wall.translation.y = (randi() % 5) + 1.0 
		wall.translation.z = (randi() % 200) - 100.0 # -100 - 99
		# size
		wall.height = wall.translation.y * 2
		wall.set_width(1) # depth
		wall.set_depth((randi() % 16) + 5.0) # 5 - 20
		
		# rotation
		if abs(wall.translation.x) < abs(wall.translation.z):
			wall.rotate_y(PI / 2)
			
		# clear start area
		if (wall.translation.x < 10 && wall.translation.x > -10)\
		&& (wall.translation.z < 10 && wall.translation.z > -10):
			wall.queue_free()
			
func generate_buildings():
	
	# number of walls
	var num_buildings = 10
	
	# building generation
	for i in num_buildings:
		var building = building_scene.instance()
		add_child(building)
		building.set_use_collision(true)
		
		# location
		building.translation.x = (randi() % 200) - 100.0 # -100 - 99
		building.translation.y = (randi() % 11) + 10.0 # 10 - 20
		building.translation.z = (randi() % 200) - 100.0 # -100 - 99
		
		# size
		building.height = building.translation.y * 2
		building.set_width((randi() % 11) + 10.0) # depth
		building.set_depth((randi() % 11) + 10.0) # 5 - 20
		
		# rotation
#		if abs(wall.translation.x) < abs(wall.translation.z):
#			wall.rotate_y(PI / 2)

		# clear start area
		if (building.translation.x < 10 && building.translation.x > -10)\
		&& (building.translation.z < 10 && building.translation.z > -10):
			building.queue_free()

func generate_trees():
	
	# number of walls
	var num_trees = 20
	
	# wall generation
	for i in num_trees:
		var tree = tree_scene.instance()
		add_child(tree)
		
		# location
		tree.translation.x = (randi() % 200) - 100.0 # -100 - 99
		tree.trunk.translation.y = (randi() % 3) + 3.0 # 3 - 5
		tree.leaves.translation.y = tree.trunk.translation.y * 2
		tree.translation.z = (randi() % 200) - 100.0 # -100 - 99
		
		# size
		tree.trunk.set_height(tree.trunk.translation.y * 2)
		tree.leaves.set_radius((randi() % 3) + 3.0)
		
		# clear start area
		if (tree.translation.x < 10 && tree.translation.x > -10)\
		&& (tree.translation.z < 10 && tree.translation.z > -10):
			tree.queue_free()
			
func generate_tunnels():
	
	var num_tunnels = 2
	
	for i in num_tunnels:
		var tunnel = tunnel_scene.instance()
		add_child(tunnel)
		
		tunnel.translation.x = (randi() % 200) - 100.0 # -100 - 99
		tunnel.translation.y = 0
		tunnel.translation.z = (randi() % 200) - 100.0 # -100 - 99
		
		var rotated = randi() % 2
		if rotated:
			tunnel.rotate_y(PI / 2)
			
		# clear start area
		if (tunnel.translation.x < 10 && tunnel.translation.x > -10)\
		&& (tunnel.translation.z < 10 && tunnel.translation.z > -10):
			tunnel.queue_free()

func generate_ramps():
	
	var num_ramps = 3
	
	for i in num_ramps:
		var ramp = ramp_scene.instance()
		add_child(ramp)
		
		ramp.translation.x = (randi() % 150) - 75.0 # -100 - 99
		ramp.translation.y = 5
		ramp.translation.z = (randi() % 150) - 75.0 # -100 - 99
		


		ramp.rotate_y(PI / 2 * (randi() % 4))
			
		# clear start area
		if (ramp.translation.x < 10 && ramp.translation.x > -10)\
		&& (ramp.translation.z < 10 && ramp.translation.z > -10):
			ramp.queue_free()
	  
func spawn_ammo():
	#number of ammo boxes
	var num_ammo = 5 + (5 * wave)
	var player_node = get_tree().get_root().find_node("Player", true, false)
	
	#generate ammo boxes
	for i in num_ammo:
		var ammo_box = ammo_scene.instance()
		add_child(ammo_box)
		ammo_box.connect("collected",player_node,"_on_Ammo_collected")
		ammo_box.collision_layer = 2
		
		#location of ammo boxes
		ammo_box.translation.x = (randi() % 170) - 100.0 
		ammo_box.translation.z = (randi() % 170) - 100.0 
		ammo_box.translation.x = (randi() % 170) - 100.0 
		ammo_box.translation.z = (randi() % 170) - 100.0 
			
		
		ammo_box.translation.y = 1

func _on_MobTimer_timeout():
	var enemy = enemy_scene.instance()
	
	var enemy_spawn_location = $EnemySpawnPath/EnemySpawnLocation
	enemy_spawn_location.unit_offset = randf()
	
	var player_position = $Player.transform.origin
	
	add_child(enemy)
	enemy.initialize(enemy_spawn_location.translation, player_position)

func _on_Player_dead():
	$MobTimer.stop()
	$Player.paused = true
	$Player.game_started = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Player/Head/Camera/HUD.hide()
	$Player/Head/Camera/UserInterface.hide()
	$CSGCombiner/ViewportContainer.hide()
	$RetryScreen.show()
	yield(get_tree().create_timer(2.0), "timeout")
	$Player.gun_ammo = 60
	$Player.gun_clip = $Player.gun_clip_capacity
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.queue_free()
	

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Enemy_dead():
	mob_count -= 1
	if mob_count <= 0:
		$WaveStartTimer.start()

func _on_WaveStartTimer_timeout():
	wave += 1
	var spawn_count = 10 + (5 * wave)
	wave_label.text = "Wave " + str(wave)
	wave_label.show()
	yield(get_tree().create_timer(2.0), "timeout")
	wave_label.hide()
	spawn_ammo()
	
	for i in spawn_count:
		var enemy = enemy_scene.instance()
		add_child(enemy)
		
		enemy.translation.x = (randi() % 200) - 100.0 # -100 - 99
		enemy.translation.y = 45.0
		enemy.translation.z = (randi() % 200) - 100.0 # -100 - 99
		
		#var player_position = $Player.transform.origin
		
		enemy.connect("dead", main, "_on_Enemy_dead")
		mob_count += 1

func pause_game():
	$Player.paused = true
	$MobTimer.paused = true
	paused = true
	$PauseMenu.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func unpause_game():
	$MobTimer.paused = false
	$Player.paused = false
	paused = false
	$PauseMenu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
