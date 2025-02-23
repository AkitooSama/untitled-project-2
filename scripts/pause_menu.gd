extends Control

@onready var background: ColorRect = $Background
@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/PauseMenuOptions/ResumeButton

@onready var master_slider: HSlider = $Panel/PauseMenuOptions/MasterVolumeContainer/MasterSlider
@onready var sfx_slider: HSlider =$Panel/PauseMenuOptions/SFXVolumeContainer/SFXSlider
@onready var player_slider: HSlider = $Panel/PauseMenuOptions/PlayerVolumeContainer/PlayerSlider

@onready var quit_button: Button = $Panel/PauseMenuOptions/QuitButton

@onready var hover_sound: AudioStreamPlayer = $HoverSound

const SAVE_PATH = "user://savegame.json"

var is_paused = false
var fade_speed = 4.0
var game_manager

var save_data = {}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_save_data()
	_apply_settings()
	game_manager = get_parent().get_parent().find_child("GameManager", true, false)
	
	resume_button.pressed.connect(_on_resume_pressed)
	
	master_slider.value_changed.connect(_on_master_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	player_slider.value_changed.connect(_on_player_volume_changed)
	
	quit_button.pressed.connect(_on_quit_pressed)

	for button in [resume_button, quit_button]:
		button.mouse_entered.connect(_play_hover_sound)

	visible = false
	background.modulate.a = 0.0
	panel.modulate.a = 0.0

func load_save_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		if content:
			save_data = JSON.parse_string(content)
		file.close()
		save_to_file()

func save_to_file():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

func save_settings():
	save_data["settings"]["master_volume"] = master_slider.value
	save_data["settings"]["effects_volume"] = sfx_slider.value
	save_data["settings"]["player_volume"] = player_slider.value
	save_to_file()

func _input(event):
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused

	if is_paused:
		_sync_with_camera()
		_show_pause_menu()
	else:
		save_settings()
		_hide_pause_menu() 
 
func _sync_with_camera():
	if game_manager and game_manager.current_player and game_manager.current_player.camera:
		var viewport_size = get_viewport_rect().size

		global_position = Vector2.ZERO
		size = viewport_size
		custom_minimum_size = viewport_size
		scale = Vector2.ONE  

		visible = true
  
func _show_pause_menu():
	load_save_data()
	_apply_settings()
	visible = true
	resume_button.grab_focus()
	_fade_in()

func _hide_pause_menu():
	await _fade_out()
	visible = false

func _fade_in():
	while background.modulate.a < 1.0:
		background.modulate.a += fade_speed * get_process_delta_time()
		panel.modulate.a += fade_speed * get_process_delta_time()
		await get_tree().process_frame

func _fade_out():
	while background.modulate.a > 0.0:
		background.modulate.a -= fade_speed * get_process_delta_time()
		panel.modulate.a -= fade_speed * get_process_delta_time()
		await get_tree().process_frame
	return false

func _on_resume_pressed():
	save_settings()
	_toggle_pause()

func _on_quit_pressed():
	save_settings()
	get_tree().quit()

func _play_hover_sound():
	if hover_sound and not hover_sound.playing:
		hover_sound.play()

func _apply_settings():
	_apply_audio_settings()

func _apply_audio_settings():	
	master_slider.min_value = 0.0
	master_slider.max_value = 1.0
	
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	
	player_slider.min_value = 0.0
	player_slider.max_value = 1.0

	master_slider.value = save_data["settings"]["master_volume"]
	sfx_slider.value = save_data["settings"]["effects_volume"]
	player_slider.value = save_data["settings"]["player_volume"]

func _on_master_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_sfx_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_player_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Player"), linear_to_db(value))
