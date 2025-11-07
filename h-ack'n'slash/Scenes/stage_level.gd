extends Node2D

@onready var SceneTransitionAnimation = $"Scene Transition/AnimationPlayer"
@onready var player_camera = $Player/Camera2D
# Called when the node enters the scene tree for the first time.
func _ready():
	SceneTransitionAnimation.get_parent().get_node("ColorRect").color.a = 225
	SceneTransitionAnimation.play("fade_out")
	player_camera.enabled = true
	Global.playerWeaponEquip = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Global.playerAlive:
		Global.gameStarted = false
		SceneTransitionAnimation.play("fade_in")
		get_tree().change_scene_to_file("res://Scenes/lobby_level.tscn")
