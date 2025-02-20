extends AudioStreamPlayer2D

func _ready():
	randomize()
	glitch_audio()

func glitch_audio():
	while true:
		await get_tree().create_timer(randf_range(2, 5)).timeout
		var glitch_amount = randf_range(0.95, 1.05)
		pitch_scale = glitch_amount
		volume_db = -randf_range(0.2, 2)
		await get_tree().create_timer(0.2).timeout
		pitch_scale = 1.0
		volume_db = 0.0
