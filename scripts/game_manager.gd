extends Node

@onready var score_label: Label = $ScoreLabel
@onready var player_one: CharacterBody2D = $Level/Players/NavigationRegion2D/PlayerOne
@onready var player_two: CharacterBody2D = $Level/Players/NavigationRegion2D/PlayerTwo

var score = 0
var current_player

func _ready():
	set_controlled_player(player_two)

func _input(event):
	if event.is_action_pressed("switch_player"):
		switch_player()
	elif event.is_action_pressed("toggle_follow"):
		toggle_follow_status()

func set_controlled_player(new_player):
	if current_player:
		current_player.previous_state = {
			"is_following": current_player.is_following,
			"velocity": current_player.velocity
		}

		current_player.is_controlled = false  

	current_player = new_player
	current_player.is_controlled = true  

	if "is_following" in current_player.previous_state:
		current_player.is_following = current_player.previous_state["is_following"]
		current_player.velocity = current_player.previous_state["velocity"]

	if current_player.camera:
		current_player.camera.make_current()

func switch_player():
	if current_player == player_one:
		set_controlled_player(player_two)
		current_player.follow_target = player_one
	else:
		set_controlled_player(player_one)
		current_player.follow_target = player_two


func toggle_follow_status():
	current_player.is_following = not current_player.is_following

func add_score():
	score += 100
	score_label.text = "score: " + str(score)
