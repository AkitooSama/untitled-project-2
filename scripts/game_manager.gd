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
				{"speaker": 1, "text": "Ugh... my head. What—? Where are we?"},
				{"speaker": 2, "text": "...This isn't our office."},
				{"speaker": 1, "text": "Yeah, no kidding. It looks like... a game? But something’s off."},
				{"speaker": 2, "text": "The air feels... heavy. Like something's broken."},
				{"speaker": 1, "text": "I feel like I should know this place. But I don’t. It’s just... blank."},
				{"speaker": 2, "text": "...Me too. But I know you."},
				{"speaker": 1, "text": "Yeah. I know you too. That’s weird, right?"},
				{"speaker": 2, "text": "Very."},
				{"speaker": 1, "text": "Okay, let’s focus. There's gotta be a way forward."},
				{"speaker": 2, "text": "...The ground. It keeps flickering."},
				{"speaker": 1, "text": "So does that wall over there. Like it's not finished."},
				{"speaker": 2, "text": "Then we better be careful. Whatever this place is... it's unstable."}
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
