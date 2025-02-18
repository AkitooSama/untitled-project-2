extends CharacterBody2D


@export var speed = 200
var player_pos
@export var player: CharacterBody2D

func _physics_process(delta: float) -> void:
	if player != null:
		player_pos = player.position
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if player == null:
		velocity.x = 0
	elif player_pos.x < position.x:
		velocity.x = -1 * speed
	elif player_pos.x > position.x:
		velocity.x = 1 * speed
	
	
	move_and_slide()

func take_damage(amount: int) -> void:
	print("Damage: ", amount)
	#play death anim (queue_free() at end of death anim)
	queue_free()
