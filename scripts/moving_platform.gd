extends Node2D

@onready var animation_player: AnimationPlayer = $Platform/AnimationPlayer
@onready var ray_cast_2d_right: RayCast2D = $Platform/RayCast2DRight
@onready var ray_cast_2d_left: RayCast2D = $Platform/RayCast2DLeft

var speed_scale: float = 100.0
var direction: int = 1

var codable_vars = {
	"Names": ["speed_scale"],
	"Vars": [speed_scale]
}

func _process(delta):
	speed_scale = codable_vars["Vars"][0]
	position.x += direction * speed_scale * delta

	if ray_cast_2d_right.is_colliding():
		direction = -1
	elif ray_cast_2d_left.is_colliding():
		direction = 1

func _on_area_entered(_area: Area2D) -> void:
	pass
	#print("Moving platform detected by debugger!")

func _on_area_exited(_area: Area2D) -> void:
	pass
	#print("Moving platform removed from debugger!")
