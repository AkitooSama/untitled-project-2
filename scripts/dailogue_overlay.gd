extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var player_one_dailogues: Label = $ColorRect/PlayerOneDailogues
@onready var player_two_dailogues: Label = $ColorRect/PlayerTwoDailogues
@onready var typing_sound = $TypingSound

var dialogues = []
var current_index = 0
var is_typing = false
var fade_speed = 2.0
var game_manager

func _ready():
	color_rect.modulate.a = 0.0
	player_one_dailogues.text = ""
	player_one_dailogues.text = ""
	game_manager = get_parent().get_parent().find_child("GameManager", true, false)

	_fade_in()

func start_dialogue(dialogue_list: Array):
	dialogues = dialogue_list
	current_index = 0
	_show_next_line()

func _show_next_line():
	if current_index >= dialogues.size():
		_fade_out()
		return

	var dialogue = dialogues[current_index]
	current_index += 1
	
	player_one_dailogues.text = ""
	player_two_dailogues.text = ""

	if dialogue["speaker"] == 1:
		_typing_effect(player_one_dailogues, dialogue["text"])
	else:
		_typing_effect(player_two_dailogues, dialogue["text"])

func _typing_effect(label: Label, text: String):
	is_typing = true
	label.visible = true
	label.text = ""

	for i in range(text.length()):
		label.text += text[i]
		if typing_sound and not typing_sound.playing:
			typing_sound.play()
		await get_tree().create_timer(0.05).timeout

	await get_tree().create_timer(1.5).timeout
	is_typing = false
	_show_next_line()

func _fade_in():
	while color_rect.modulate.a < 1.0:
		color_rect.modulate.a += fade_speed * get_process_delta_time()
		await get_tree().process_frame

func _fade_out():
	while color_rect.modulate.a > 0.0:
		color_rect.modulate.a -= fade_speed * get_process_delta_time()
		await get_tree().process_frame
	get_tree().paused = false
	game_manager.dailogue_played = true
	queue_free()
