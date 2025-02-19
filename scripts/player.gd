extends CharacterBody2D

@export var follow_target: Node2D = null
@export var is_controlled: bool = false
@export var is_following: bool = false
@export var Deebugger_Detecter: Area2D
@export var prompt: CanvasLayer
@export var prompt_txt: TextEdit

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const FOLLOW_SPEED_MULTIPLIER = 0.7
const FOLLOW_DISTANCE = 80.0  

var deebug_mode = false
var deebugObjList = []

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $SFX/JumpSound
@onready var dying_sound: AudioStreamPlayer2D = $SFX/DyingSound
@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var previous_state: Dictionary = {"is_following": false, "velocity": Vector2.ZERO}

var navigation_ready: bool = false

func _ready():
	await get_tree().process_frame  
	navigation_ready = true
	nav_agent.path_desired_distance = 10
	nav_agent.target_desired_distance = FOLLOW_DISTANCE

func _physics_process(delta: float) -> void:
	if is_controlled:
		handle_movement(delta)
		camera.make_current()
	else:
		if is_following and follow_target:
			follow_player(delta)

	move_and_slide()

func handle_movement(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	# Debugger
	if Input.is_action_just_pressed("Deebug") && deebug_mode == false:
		deebug_mode = true
		prompt.show()
		var list_length = deebugObjList.size()
		for i in list_length:
			prompt_txt.text += str(deebugObjList[i - 1], "\n")
	elif Input.is_action_just_pressed("Deebug") && deebug_mode == true:
		deebug_mode = false
		prompt.hide()
		prompt_txt.text = ""

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

func follow_player(_delta):
	print("Follow Player Function Called")

	if not is_following:
		print("Not following (is_following == false)")
		return  

	if not follow_target:
		print("No follow target assigned!")
		return  

	# Debug: Print current positions
	print("Follow Target Position:", follow_target.position)
	print("Agent Current Position:", position)

	# Ensure NavigationAgent2D updates path
	if nav_agent.target_position != follow_target.position:
		nav_agent.set_target_position(follow_target.position)
		print("🚀 Path Updated! New Target Position:", nav_agent.target_position)

	# Get next path position
	var next_position = nav_agent.get_next_path_position()
	if next_position == Vector2.ZERO:
		print("🚨 ERROR: No valid path! Pathfinding might be broken.")
		return  

	# Calculate movement
	var distance = position.distance_to(next_position)
	print("Distance to Next Position:", distance)

	if distance > FOLLOW_DISTANCE:
		var direction = (next_position - position).normalized()
		velocity = velocity.lerp(direction * SPEED * FOLLOW_SPEED_MULTIPLIER, 0.1)
		print("Following... Moving towards", next_position)
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.1)
		print("Close enough to target. Stopping.")


# Handle Taking Damage
func take_damage(amount: int) -> void:
	print("Damage: ", amount)
	Engine.time_scale = 0.5
	dying_sound.play()
	collision_shape_2d.queue_free()

# Debugger Functions
func _on_deebugger_range_area_entered(area: Area2D) -> void:
	deebugObjList.append(area.codable_vars)

func _on_deebugger_range_area_exited(area: Area2D) -> void:
	deebugObjList.erase(area.codable_vars)
