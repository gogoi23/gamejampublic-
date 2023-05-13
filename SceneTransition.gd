# SceneTransition.gd
# Author: Jordan Nakamura, Logan Machida, Dylan Kramis, Trey Dettmer
# Version: 10/8/2022
extends CanvasLayer

#variables
onready var fade_animation = $Control/AnimationPlayer
var scene : String

#takes a scene and animaiton to transition to new scene
func change_scene(new_scene, animation):
	scene = new_scene
	fade_animation.play(animation)

#transitions to new scene
func _new_scene():
	get_tree().change_scene(scene)

