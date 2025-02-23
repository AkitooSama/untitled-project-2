extends StaticBody2D


@export var group: Node2D

var plates = []

func _ready() -> void:
	plates.append_array(group.get_children())
	for i in plates:
		print(i.power)

func _physics_process(delta: float) -> void:
	var all_powered = true
	for plate in plates:
		if not plate.power:
			all_powered = false
	
	if all_powered == true:
		queue_free()
