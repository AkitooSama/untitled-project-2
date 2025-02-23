extends Node2D

const SPEED = 60
var direction = 1

@onready var ray_cast_2d_right: RayCast2D = $RayCast2DRight
@onready var ray_cast_2d_left: RayCast2D = $RayCast2DLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_timer: Timer = $DeathTimer

func _process(delta: float) -> void:
	if ray_cast_2d_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
	if ray_cast_2d_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
	
	position.x += direction * SPEED * delta
	
	if Input.is_action_just_pressed("jump"):
		take_damage(10)

func take_damage(amount: int) -> void:
	direction = 0
	animated_sprite_2d.play("death")
	death_timer.start()
	
func _on_death_timer_timeout() -> void:
	queue_free()
