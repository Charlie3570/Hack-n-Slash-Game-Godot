extends Node2D

@onready var SceneTransitionAnimation = $"Scene Transition/AnimationPlayer"
@onready var player_camera = $Player/Camera2D
# Called when the node enters the scene tree for the first time.
func _ready():
	SceneTransitionAnimation.get_parent().get_node("ColorRect").color.a = 225
	SceneTransitionAnimation.play("fade_out")
	player_camera.enabled = false
	Global.playerWeaponEquip = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_direction_body_entered(body):
	if body is Player:
		Global.gameStarted = true
		
		SceneTransitionAnimation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scenes/stage_level.tscn")
