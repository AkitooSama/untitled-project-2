extends Area2D
signal power_on 

@onready var click_sound: AudioStreamPlayer2D = $SFX/ClickSound
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var sprite: Sprite2D = $UnpressedSprite

var sound_played = false
var power = false  

var codable_vars = {
	"Names": ["power"],
	"Vars": [power]
}

func _physics_process(_delta: float) -> void:
	power = codable_vars["Vars"][0]
	if power == true:
		point_light_2d.enabled = true
	if power == false:
		point_light_2d.enabled = false

func _on_area_entered(_area: Area2D) -> void:
	codable_vars["Vars"][0] = true
	power = true
	click_sound.play()
	point_light_2d.enabled = true
	sound_played = true
	sprite.hide()

func _on_area_exited(_area: Area2D) -> void:
	codable_vars["Vars"][0] = false
	power = false
	sound_played = false
	sprite.show()
	point_light_2d.enabled = false
