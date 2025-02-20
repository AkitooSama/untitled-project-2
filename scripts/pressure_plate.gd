extends Area2D
signal power_on 

@onready var click_sound: AudioStreamPlayer2D = $SFX/ClickSound
@onready var point_light_2d: PointLight2D = $PointLight2D

var sound_played = false
var power = false  

var codable_vars = {
	"Names": ["power"],
	"Vars": [power]
}

func _physics_process(_delta: float) -> void:
	power = codable_vars["Vars"][0]

	if power:
		point_light_2d.enabled = true
	else:
		point_light_2d.enabled = false

func _on_area_entered(_area: Area2D) -> void:
	print("Player stepped on plate")
	if not sound_played:
		click_sound.play()
		sound_played = true
	if power:
		emit_signal("power_on")

func _on_area_exited(_area: Area2D) -> void:
	sound_played = false
	print("Player left plate")
