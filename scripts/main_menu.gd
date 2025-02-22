extends Node

const SAVE_PATH = "user://savegame.json"

@onready var buttons_container = $MenuOptions
@onready var settings_menu = $SettingsMenuOptions

@onready var start_button = $MenuOptions/StartButton
@onready var levels_button: Button = $MenuOptions/LevelsButton
@onready var settings_button = $MenuOptions/SettingsButton
@onready var quit_button = $MenuOptions/QuitButton

@onready var level_select_menu: VBoxContainer = $LevelSelectMenu

@onready var hover_sound = $HoverSound

@onready var master_slider: HSlider = $SettingsMenuOptions/MasterVolumeContainer/MasterSlider
@onready var sfx_slider: HSlider = $SettingsMenuOptions/SFXVolumeContainer/SFXSlider
@onready var player_slider: HSlider = $SettingsMenuOptions/PlayerVolumeContainer/PlayerSlider
@onready var fullscreen_toggle: CheckButton = $SettingsMenuOptions/FullscreenContainer/FullscreenToggle
@onready var back_button = $SettingsMenuOptions/BackButton

var save_data = {}

var current_index = 0
var buttons = []

func _ready():
	load_save_data()
	
	if save_data["unlocked_levels"].is_empty():
		levels_button.hide()
	else:
		start_button.text = "• CONTINUE GAME •"
		
	buttons = [start_button, levels_button, settings_button, quit_button, back_button]
	level_select_menu.hide()
	settings_menu.hide()

	start_button.pressed.connect(_on_start_pressed)
	levels_button.pressed.connect(_on_levels_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_back_pressed)

	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	master_slider.value_changed.connect(_on_master_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	player_slider.value_changed.connect(_on_player_volume_changed)

	for button in buttons:
		button.mouse_entered.connect(_play_hover_sound)

	_apply_settings()
	buttons[current_index].grab_focus()

func _play_hover_sound():
	if hover_sound and not hover_sound.playing:
		hover_sound.play()

func load_save_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		if content:
			save_data = JSON.parse_string(content)
		else:
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
		file.close()
	else:
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
		save_to_file()

func save_to_file():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

func _on_start_pressed():
	var last_level = save_data["player_progress"]["last_level"]
	if last_level == 0:
		get_tree().change_scene_to_file("res://scenes/crash_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://levels/level_%d.tscn" % last_level)

func _on_settings_pressed():
	load_save_data()
	_apply_settings()
	buttons_container.hide()
	settings_menu.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_levels_pressed():
	buttons_container.hide()
	level_select_menu.show()
	
func _on_back_pressed():
	save_settings()
	settings_menu.hide()
	buttons_container.show()

func save_settings():
	save_data["settings"]["master_volume"] = master_slider.value
	save_data["settings"]["effects_volume"] = sfx_slider.value
	save_data["settings"]["player_volume"] = player_slider.value
	save_data["settings"]["fullscreen"] = fullscreen_toggle.button_pressed
	save_to_file()

func _apply_settings():
	master_slider.value = save_data["settings"]["master_volume"]
	sfx_slider.value = save_data["settings"]["effects_volume"]
	player_slider.value = save_data["settings"]["player_volume"]
	fullscreen_toggle.button_pressed = save_data["settings"]["fullscreen"]
	_apply_audio_settings()
	_apply_fullscreen()

func _apply_audio_settings():
	var master_index = AudioServer.get_bus_index("Master")
	var sfx_index = AudioServer.get_bus_index("SFX")
	var player_index = AudioServer.get_bus_index("Player")
	
	master_slider.min_value = 0.0
	master_slider.max_value = 1.5
	
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.5
	
	player_slider.min_value = 0.0
	player_slider.max_value = 1.5

	AudioServer.set_bus_volume_db(master_index, linear_to_db(master_slider.value))
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(sfx_slider.value))
	AudioServer.set_bus_volume_db(player_index, linear_to_db(player_slider.value))

func _apply_fullscreen():
	if fullscreen_toggle.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_master_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_sfx_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_player_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Player"), linear_to_db(value))

func _on_fullscreen_toggled(toggled_on):
	save_data["settings"]["fullscreen"] = toggled_on
	_apply_fullscreen()
	
