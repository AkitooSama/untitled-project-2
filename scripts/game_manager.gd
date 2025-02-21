extends Node

@onready var player_one: CharacterBody2D = $Level/Players/PlayerOne
@onready var player_two: CharacterBody2D = $Level/Players/PlayerTwo
@onready var dailogue_overlay: Node2D = $"../CanvasLayer/DailogueOverlay"

var score = 0
var dailogue_played: bool = false
var current_player

func _ready():
	set_controlled_player(player_one)

func _input(event):
	if event.is_action_pressed("switch_player"):
		switch_player()

	if event.is_action_pressed("dailogue"):
		if not dailogue_played:
			dailogue_overlay.start_dialogue([
				{"speaker": 1, "text": "Hey, what's going on?"},
				{"speaker": 2, "text": "We need to move fast!"},
				{"speaker": 1, "text": "Alright, let's go!"},
				{"speaker": 2, "text": "Be careful out there."}
			])
			get_tree().paused = true
		
	elif event.is_action_pressed("toggle_follow"):
		toggle_follow_status()

func switch_player():
	if current_player:
		current_player.is_controlled = false  

		if current_player.debug_mode:
			current_player.debug_mode = false
			if current_player.has_node("Debugger"):
				current_player.get_node("Debugger").close_debugger()

	var new_player = player_two if current_player == player_one else player_one
	set_controlled_player(new_player)

func set_controlled_player(new_player):
	if current_player:
		current_player.is_controlled = false  
		current_player.debug_mode = false

	current_player = new_player
	current_player.is_controlled = true  

	if current_player.camera:
		current_player.camera.make_current()

func toggle_follow_status():
	if not current_player:
		return

	current_player.is_following = not current_player.is_following
