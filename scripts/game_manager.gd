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
	load_save_data()
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
	elif event.is_action_pressed("toggle_follow"):
		toggle_follow_status()

	if save_data["unlocked_levels"].is_empty():
		if event.is_action_pressed("dailogue"):
			if not dailogue_played:
				dailogue_overlay.start_dialogue([
					{"speaker": 1, "text": "...Ugh. My head. What—? Where are we?"},
					{"speaker": 2, "text": "...This isn’t right. This isn’t our office."},
					{"speaker": 1, "text": "No kidding. It looks like... a game? But something’s wrong."},
					{"speaker": 2, "text": "The air feels heavy. Like the world itself is... breaking."},
					{"speaker": 1, "text": "I feel like I should recognize this place, but I don’t. It’s just... empty."},
					{"speaker": 2, "text": "...Yeah. Same. But I know *you*."},
					{"speaker": 1, "text": "I know *you* too. That’s weird, right?"},
					{"speaker": 2, "text": "Very."},
					{"speaker": 1, "text": "Alright. We need to focus. There has to be a way out of here."},
					{"speaker": 2, "text": "We better be careful. This whole place... is.."}
				])


func save_to_file():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()

func switch_player():
	if current_player:
		current_player.is_controlled = false
		current_player.velocity = Vector2.ZERO
		current_player.footstep_sound.stop()

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
	current_player.velocity = Vector2.ZERO

	if current_player.camera:
		current_player.camera.make_current()

func toggle_follow_status():
	if not current_player:
		return

	current_player.toggle_follow_status()
