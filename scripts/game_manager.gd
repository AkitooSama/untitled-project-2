extends Node

const SAVE_PATH = "user://savegame.json"

@onready var player_one: CharacterBody2D = $Level/Players/PlayerOne
@onready var player_two: CharacterBody2D = $Level/Players/PlayerTwo
@onready var dailogue_overlay: Node2D = get_parent().find_child("DailogueOverlay", true, false)

var score = 0
var dailogue_played: bool = false
var current_player
var save_data = {"unlocked_levels": []}

func _ready():
	#load_save_data()
	set_controlled_player(player_one)

func update_progress(new_last_level: int):
	save_data = load_save_data()
	
	if not save_data:
		save_data = {
			"unlocked_levels": [],
			"player_progress": {"last_level": 0},
			"settings": {
				"master_volume": 0.6,
				"effects_volume": 0.3,
				"player_volume": 0.4,
				"fullscreen": true
			}
		}
	
	save_data["player_progress"]["last_level"] = new_last_level
	
	if new_last_level not in save_data["unlocked_levels"]:
		save_data["unlocked_levels"].append(new_last_level)
	
	save_to_file()

func load_save_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		save_data = JSON.parse_string(content)
		file.close()
	return save_data

func _input(event):
	if event.is_action_pressed("switch_player"):
		switch_player()

	if save_data["unlocked_levels"].is_empty():
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
		
	elif event.is_action_pressed("toggle_follow"):
		toggle_follow_status()

func save_to_file():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()

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
