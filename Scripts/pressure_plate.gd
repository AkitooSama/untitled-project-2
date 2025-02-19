extends Area2D

var power = false
var c_name = "Power"
var c_bool = power

var codable_vars = [c_name, c_bool]
func _physics_process(delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	print("On")


func _on_area_exited(area: Area2D) -> void:
	print("off")
