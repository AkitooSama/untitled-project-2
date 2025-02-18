extends Area2D

@onready var timer: Timer = $Timer
@onready var dying_sound: AudioStreamPlayer2D = $DyingSound

func _on_body_entered(body: Node2D) -> void:
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	dying_sound.play()
	timer.start()
	
func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
