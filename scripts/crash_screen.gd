extends Control

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var vbox: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var error_label: Label = $ScrollContainer/VBoxContainer/ErrorLabel
@onready var static_noise: AudioStreamPlayer = $StaticNoise
@onready var radio_noise: AudioStreamPlayer = $RadioNoise
@onready var transition_timer: Timer = $TransitionTimer
@onready var glitch_rect: ColorRect = $GlitchRect

var file_path = "res://text/error_log.txt"
var lines = []
var typing_speed = 0.001
var max_visible_lines = 82

var elapsed_time = 0.0
var line_index = 0

func _ready():
	material = glitch_rect.material
	material.set_shader_parameter("glitch_intensity", 0.8)
	material.set_shader_parameter("scanline_speed", 3.0)
	material.set_shader_parameter("scanline_intensity", 0.2)

	load_text_file(file_path)
	static_noise.play()
	radio_noise.play()

func _process(delta: float) -> void:
	if line_index >= lines.size():
		pause_shader()
		radio_noise.stop()
		return
	
	elapsed_time += delta
	if elapsed_time >= typing_speed:
		elapsed_time = 0.0
		
		error_label.text += lines[line_index] + "\n"
		line_index += 1

		var visible_lines = error_label.text.split("\n")
		if visible_lines.size() > max_visible_lines:
			visible_lines = visible_lines.slice(visible_lines.size() - max_visible_lines, visible_lines.size())
			error_label.text = "\n".join(visible_lines)
		
func load_text_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		lines = file.get_as_text().split("\n")
		file.close()
	else:
		lines = ["ERROR: Failed to load crash report.", "SYSTEM HALTED."]

func pause_shader():
	glitch_rect.material.set_shader_parameter("time_factor", 0.0)

func _on_transition_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
