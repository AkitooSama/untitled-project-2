extends Area2D
signal power_on

@export var codable_vars_names: Array[String] = ["power", "stand"]
@export var power: bool = false
@export var stand: bool = false

@onready var click_sound: AudioStreamPlayer2D = $SFX/ClickSound
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var sprite: Sprite2D = $UnpressedSprite

var sound_played = false
var codable_vars = {
	"Names": [],
	"Vars": []
}

func _ready() -> void:
	_update_codable_vars()

func _update_codable_vars() -> void:
	codable_vars["Names"] = codable_vars_names
	codable_vars["Vars"].clear()

	for name in codable_vars_names:
		match name:
			"power":
				codable_vars["Vars"].append(power)
			"stand":
				codable_vars["Vars"].append(stand)

func _set_codable_var(name: String, value: bool) -> void:
	if name in codable_vars["Names"]:
		var index = codable_vars["Names"].find(name)
		if index != -1:
			codable_vars["Vars"][index] = value

func _physics_process(_delta: float) -> void:
	_update_codable_vars()

	var is_power_on = false
	var is_standing = false

	for i in range(codable_vars["Names"].size()):
		if codable_vars["Names"][i] == "power":
			is_power_on = codable_vars["Vars"][i]
		elif codable_vars["Names"][i] == "stand":
			is_standing = codable_vars["Vars"][i]

	if "power" in codable_vars["Names"] and "stand" in codable_vars["Names"]:
		point_light_2d.enabled = is_power_on and is_standing
	elif "power" in codable_vars["Names"]:
		point_light_2d.enabled = is_power_on
	else:
		point_light_2d.enabled = false

func _on_area_entered(_area: Area2D) -> void:
	if not sound_played:
		click_sound.play()
		sound_played = true
		sprite.hide()
	
	stand = true
	_set_codable_var("stand", true)

	var is_power_on = false
	var is_standing = false

	for i in range(codable_vars["Names"].size()):
		if codable_vars["Names"][i] == "power":
			is_power_on = codable_vars["Vars"][i]
		elif codable_vars["Names"][i] == "stand":
			is_standing = codable_vars["Vars"][i]

	if "power" in codable_vars["Names"] and "stand" in codable_vars["Names"] and is_power_on and is_standing:
		emit_signal("power_on")
	elif "power" in codable_vars["Names"] and is_power_on:
		emit_signal("power_on")

func _on_area_exited(_area: Area2D) -> void:
	sound_played = false
	sprite.show()

	stand = false
	_set_codable_var("stand", false)
