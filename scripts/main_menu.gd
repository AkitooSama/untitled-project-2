extends Node

@onready var buttons_container = $MenuOptions
@onready var settings_menu = $SettingsMenuOptions

@onready var start_button = $MenuOptions/StartButton
@onready var settings_button = $MenuOptions/SettingsButton
@onready var quit_button = $MenuOptions/QuitButton

@onready var master_slider: HSlider = $SettingsMenuOptions/MasterVolumeContainer/MasterSlider
@onready var sfx_slider: HSlider = $SettingsMenuOptions/SFXVolumeContainer/SFXSlider
@onready var player_slider: HSlider = $SettingsMenuOptions/PlayerVolumeContainer/PlayerSlider
@onready var fullscreen_toggle: CheckButton = $SettingsMenuOptions/FullscreenContainer/FullscreenToggle
@onready var back_button = $SettingsMenuOptions/BackButton


var current_index = 0
var buttons = []

func _ready():
	buttons = [start_button, settings_button, quit_button]
	settings_menu.hide()

	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_back_pressed)

	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	master_slider.value_changed.connect(_on_master_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	player_slider.value_changed.connect(_on_player_volume_changed)

	_init_audio_sliders()

	fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

	buttons[current_index].grab_focus()

func _init_audio_sliders():
	var master_index = AudioServer.get_bus_index("Master")
	var sfx_index = AudioServer.get_bus_index("SFX")
	var player_index = AudioServer.get_bus_index("Player")

	master_slider.min_value = 0.0
	master_slider.max_value = 1.5
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_index))

	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.5
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_index))

	player_slider.min_value = 0.0
	player_slider.max_value = 1.5
	player_slider.value = db_to_linear(AudioServer.get_bus_volume_db(player_index))

func _on_master_volume_changed(value):
	var master_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_index, linear_to_db(value))

func _on_sfx_volume_changed(value):
	var sfx_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))

func _on_player_volume_changed(value):
	var player_index = AudioServer.get_bus_index("Player")
	AudioServer.set_bus_volume_db(player_index, linear_to_db(value))

func _input(event):
	if event.is_action_pressed("ui_down"):
		current_index = (current_index + 1) % buttons.size()
		buttons[current_index].grab_focus()
	elif event.is_action_pressed("ui_up"):
		current_index = (current_index - 1 + buttons.size()) % buttons.size()
		buttons[current_index].grab_focus()
	elif event.is_action_pressed("ui_accept"):
		buttons[current_index].emit_signal("pressed")

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed():
	buttons_container.hide()
	settings_menu.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_back_pressed():
	settings_menu.hide()
	buttons_container.show()

func _on_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	fullscreen_toggle.button_pressed = toggled_on
