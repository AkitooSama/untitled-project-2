extends CanvasLayer

@onready var background: ColorRect = $Background
@onready var info_label: Label = $Background/InfoLabel

var auto_hide_time = 10.0

func _ready():
	background.modulate.a = 0.0
	info_label.text = ""
	visible = false

func show_info(text: String):
	info_label.text = text
	visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(background, "modulate:a", 1.0, 0.5)

	await get_tree().create_timer(auto_hide_time).timeout
	hide_info()

func hide_info():
	if get_tree():
		var tween = get_tree().create_tween()
		tween.tween_property(background, "modulate:a", 0.0, 0.5)
		await tween.finished
		visible = false
