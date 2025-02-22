extends VBoxContainer

@onready var grid_container = $GridContainer
@onready var back_button = $BackButton
@onready var hover_sound = $HoverSound
@onready var select_sound = $SelectSound

const SAVE_PATH = "user://savegame.json"
var unlocked_levels = []
var save_data = {"unlocked_levels": []}
var buttons_container

func _ready():
	print(ProjectSettings.globalize_path("user://savegame.json"))
	buttons_container = get_parent().find_child("MenuOptions", true, false)
	load_save_data()
	setup_buttons()

	back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(_play_hover_sound)

func load_save_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		save_data = JSON.parse_string(content) if content else {}
		file.close()
		if save_data and "unlocked_levels" in save_data:
			unlocked_levels = save_data["unlocked_levels"]
			print(unlocked_levels)
	else:
		unlocked_levels = save_data["unlocked_levels"]

	if "unlocked_levels" in save_data and typeof(save_data["unlocked_levels"]) == TYPE_ARRAY:
		unlocked_levels = save_data["unlocked_levels"]
		unlocked_levels = unlocked_levels.map(func(x): return int(x))

func setup_buttons():
	for i in range(1, 10):
		var button = grid_container.get_node("LevelButton_" + str(i))
		button.pressed.connect(_on_level_selected.bind(i))
		if i not in unlocked_levels:
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5, 1)
		else:
			button.mouse_entered.connect(_play_hover_sound)

	var first_unlocked = []
	for i in unlocked_levels:
		first_unlocked.append(grid_container.get_node("LevelButton_" + str(i)))

	if first_unlocked.size() > 0:
		first_unlocked[0].grab_focus()

func _on_level_selected(level_id):
	select_sound.play()
	await get_tree().create_timer(0.2).timeout
	var level_path = "res://levels/level_" + str(level_id) + ".tscn"
	get_tree().change_scene_to_file(level_path)

func _on_back_pressed():
	visible = false
	buttons_container.show()
	
func _play_hover_sound():
	if not hover_sound.playing:
		hover_sound.play()
