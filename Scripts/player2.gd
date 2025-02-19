extends CharacterBody2D

@export var Deebugger_Detecter: Area2D
@export var prompt: CanvasLayer
@export var prompt_txt: TextEdit

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var deebug_mode = false

var deebugObjList = []

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handles jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("Attack"):
		pass
		#>play animation that enables hitbox, then disables it at the end

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

	# Gets the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("Left", "Right")
	if direction && deebug_mode == false:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func take_damage(amount: int) -> void:
	print("Damage: ", amount)
	#play death anim (queue_free() at end of death anim)
	queue_free()


func _on_deebugger_range_area_entered(area: Area2D) -> void:
	deebugObjList.append(area.codable_vars)


func _on_deebugger_range_area_exited(area: Area2D) -> void:
	deebugObjList.erase(area.codable_vars)
