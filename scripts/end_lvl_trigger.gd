extends Area2D


@export var player1: CharacterBody2D
@export var player2: CharacterBody2D

var players = []

func _on_body_entered(body: Node2D) -> void:
	players.append(body)
	if players.has(player1) && players.has(player2):
		var current_scene_file = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene_file.to_int() + 1
		print(next_level_number)


func _on_body_exited(body: Node2D) -> void:
	players.erase(body)
