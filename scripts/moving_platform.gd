extends Area2D

@onready var animation_player: AnimationPlayer = $MovingPlatform/AnimationPlayer

var speed_scale: float = 5.0

var codable_vars = {
	"Names": ["speed_scale"],
	"Vars": [speed_scale]
}

func _ready():
	animation_player.speed_scale = speed_scale

func _process(_delta):
	speed_scale = codable_vars["Vars"][0]
	animation_player.speed_scale = speed_scale

func _on_area_entered(_area: Area2D) -> void:
	print("Moving platform detected by debugger!")

func _on_area_exited(_area: Area2D) -> void:
	print("Moving platform removed from debugger!")
