extends CharacterBody2D

@export var Deebugger_Detecter: Area2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var DeebugObjList = []

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $SFX/JumpSound
@onready var dying_sound: AudioStreamPlayer2D = $SFX/DyingSound
@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	# Handle Attack
	if Input.is_action_just_pressed("Attack"):
		pass
		# Play animation that enables hitbox, then disables it at the end

	# Debugger
	if Input.is_action_just_pressed("Deebug"):
		print(DeebugObjList)

	# Movement & Animation Handling
	var direction := Input.get_axis("Left", "Right")
	
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Handle Taking Damage
func take_damage(amount: int) -> void:
	print("Damage: ", amount)
	Engine.time_scale = 0.5
	dying_sound.play()
	collision_shape_2d.queue_free()

# Debugger Functions
func _on_deebugger_range_area_entered(area: Area2D) -> void:
	DeebugObjList.append(area)

func _on_deebugger_range_area_exited(area: Area2D) -> void:
	DeebugObjList.erase(area)
