extends Area2D

@export var info_text: String = ""

var info_box: CanvasLayer

func _ready():
	info_box = get_tree().current_scene.find_child("InfoBox", true, false)
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if info_box:
		info_box.show_info(info_text)  

func _on_body_exited(body):
	if info_box:
		info_box.hide_info()
