extends Area2D


@export var player_one: CharacterBody2D
@export var player_two: CharacterBody2D

@export var torch: Node2D
@export var lights: Node2D

@onready var lights_off_timer: Timer = $LightsOffTimer
@onready var next_level_load_timer: Timer = $NextLevelLoadTimer

var players = []

func _on_body_entered(body: Node2D) -> void:
	players.append(body)
	if players.has(player_one) && players.has(player_two):
		torch.hide()
		lights_off_timer.start()

func _on_body_exited(body: Node2D) -> void:
	players.erase(body)

func _on_lights_off_timer_timeout() -> void:
	lights.hide()
	next_level_load_timer.start()

func _on_next_level_load_timer_timeout() -> void:
	var current_scene_file = get_tree().current_scene.scene_file_path
	var next_level_number = current_scene_file.to_int() + 1
	var next_level_path = "res://levels/level_" + str(next_level_number) + ".tscn"
	get_tree().change_scene_to_file((next_level_path))
