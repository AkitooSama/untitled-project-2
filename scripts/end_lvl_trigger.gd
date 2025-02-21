extends Area2D


@export var player1: CharacterBody2D
@export var player2: CharacterBody2D
@export var torch: Node2D
@export var lights: Node2D

@onready var timer1 = $Timer
@onready var timer2 = $Timer2

var players = []

func _on_body_entered(body: Node2D) -> void:
	players.append(body)
	if players.has(player1) && players.has(player2):
		torch.hide()
		timer1.start()

func _on_body_exited(body: Node2D) -> void:
	players.erase(body)

func _on_timer_timeout() -> void:
	lights.hide()
	timer2.start()

func _on_timer_2_timeout() -> void:
	var current_scene_file = get_tree().current_scene.scene_file_path
	var next_level_number = current_scene_file.to_int() + 1
	var next_level_path = "res://levels/lvl_" + str(next_level_number) + ".tscn"
	get_tree().change_scene_to_file((next_level_path))
