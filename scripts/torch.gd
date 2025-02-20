extends Node2D

@onready var torch_light: PointLight2D = $PointLight2D

@export var base_energy: float = 1.2
@export var flicker_intensity_range: Vector2 = Vector2(0.8, 1.1)
@export var flicker_speed: float = 10.0
@export var base_scale: float = 1.7
@export var scale_variation: float = 0.1
@export var scale_speed: float = 4.0
@export var texture_scale_variation: float = 0.2
@export var texture_scale_speed: float = 2.0

var time_elapsed: float = 0.0

func _process(delta):
	time_elapsed += delta
	
	if not torch_light:
		return

	var flicker_intensity = lerp(
		flicker_intensity_range.x, 
		flicker_intensity_range.y, 
		(sin(time_elapsed * flicker_speed * 1.2) * 0.4 + (sin(time_elapsed * flicker_speed * 0.8) * 0.3 + 0.5))
	)
	
	var flicker_scale = base_scale + (
		cos(time_elapsed * scale_speed) * scale_variation * 0.6 +
		sin(time_elapsed * scale_speed * 1.5) * scale_variation * 0.4
	)
	
	var texture_scale = 1.0 + (
		sin(time_elapsed * texture_scale_speed) * texture_scale_variation * 0.7 +
		cos(time_elapsed * texture_scale_speed * 2.0) * texture_scale_variation * 0.3
	)

	torch_light.energy = base_energy * flicker_intensity
	torch_light.scale = Vector2(flicker_scale, flicker_scale).lerp(torch_light.scale, 0.8)
	torch_light.texture_scale = texture_scale

func boost_light():
	if torch_light:
		torch_light.energy *= 1.2
