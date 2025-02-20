extends CharacterBody2D

@export var follow_target: CharacterBody2D = null
@export var is_controlled: bool = false
@export var is_following: bool = false

const SPEED = 270.0
const JUMP_VELOCITY = -300.0
const FOLLOW_SPEED_MULTIPLIER = 0.5
const FOLLOW_DISTANCE = 15.0

@onready var footstep_sound: AudioStreamPlayer2D = $SFX/FootStepSound
@onready var jump_dust: GPUParticles2D = $GPUParticles2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var torch: Node2D = $Torch if has_node("Torch") else null
@onready var jump_sound: AudioStreamPlayer2D = $SFX/JumpSound
@onready var dying_sound: AudioStreamPlayer2D = $SFX/DyingSound
@onready var camera: Camera2D = $Camera2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var was_in_air = false
var debug_mode = false
var is_typing = false

func _physics_process(delta: float) -> void:
	if is_typing:
		return

	if not is_on_floor():
		was_in_air = true
	elif was_in_air:
		jump_dust.restart()
		jump_dust.emitting = true
		was_in_air = false

	if is_controlled:
		handle_movement(delta)
		camera.make_current()
	elif is_following:
		follow_player(delta)

	move_and_slide()

func handle_movement(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
		jump_dust.restart()
		jump_dust.emitting = true
		if torch:
			torch.boost_light()

	var direction = Input.get_axis("Left", "Right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)

	if direction != 0 and is_on_floor():
		if not footstep_sound.playing:
			footstep_sound.play()
	else:
		footstep_sound.stop()

	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	if is_on_floor():
		animated_sprite_2d.play("idle" if direction == 0 else "run")
	else:
		animated_sprite_2d.play("jump")

func follow_player(delta):
	if not follow_target:
		return

	var distance = global_position.distance_to(follow_target.global_position)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if distance > FOLLOW_DISTANCE:
		var direction = (follow_target.global_position - global_position).normalized()
		var follow_speed = SPEED * FOLLOW_SPEED_MULTIPLIER * clamp(distance / FOLLOW_DISTANCE, 0.5, 1.5)
		velocity.x = direction.x * follow_speed

		if velocity.x > 0:
			animated_sprite_2d.flip_h = false
		elif velocity.x < 0:
			animated_sprite_2d.flip_h = true

		if follow_target.velocity.y < -50 and is_on_floor():
			velocity.y = JUMP_VELOCITY  

		if is_on_floor():
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("jump")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite_2d.play("idle")
