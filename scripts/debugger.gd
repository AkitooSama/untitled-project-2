extends Area2D

@export var player: CharacterBody2D

@onready var prompt = $CanvasLayer
@onready var prompt_txt = $CanvasLayer/TextEdit

@onready var typing_sound: AudioStreamPlayer2D = $SFX/TypingSound
@onready var enter_sound: AudioStreamPlayer2D = $SFX/EnterSound
@onready var open_debugger_sound: AudioStreamPlayer2D = $SFX/OpenDebuggerSound

@onready var collision_shape = $CollisionShape2D
@onready var sprite : Sprite2D = $CollisionShape2D/Sprite2D

@onready var exit_button: Button = $CanvasLayer/ExitButton

var debugObjList = []
var is_typing = false

func _ready():
	if player == null:
		queue_free()
		
	update_sprite_size()
	prompt_txt.text_changed.connect(_on_text_changed)

func _process(_delta: float) -> void:
	if player == null or player.debug_mode == null:
		return  
	
	if not player.is_controlled and player.debug_mode:
		close_debugger()
		open_debugger_sound.play()

	if player.debug_mode and not is_typing:
		update_debug_text()

	if Input.is_action_just_pressed("debug") and player.is_controlled:
		if player.debug_mode:
			close_debugger()
			open_debugger_sound.play()
		else:
			open_debugger()
			open_debugger_sound.play()
			

	if Input.is_action_just_pressed("enter") and player.debug_mode:
		apply_debug_changes()
		is_typing = false
		enter_sound.play()

	if is_typing:
		Input.action_release("left")
		Input.action_release("right")
		Input.action_release("jump")

func open_debugger():
	player.debug_mode = true
	prompt.show()
	sprite.show()
	update_debug_text()

func close_debugger():
	player.debug_mode = false
	prompt.hide()
	sprite.hide()
	prompt_txt.text = ""
	is_typing = false  

func update_debug_text():
	if not player.debug_mode:
		return 

	var old_cursor_pos = prompt_txt.get_caret_column()

	var new_text = ""
	for obj in debugObjList:
		if obj.has("Names") and obj.has("Vars"):
			for i in range(obj["Names"].size()):
				new_text += str(obj["Names"][i], ": ", obj["Vars"][i], "\n")

	if prompt_txt.text != new_text:
		prompt_txt.text = new_text
		prompt_txt.set_caret_column(old_cursor_pos)

func apply_debug_changes():
	var lines = prompt_txt.text.split("\n")
	var updated_text = ""

	for i in range(lines.size()):
		var line = lines[i]
		var parts = line.split(": ")
		
		if parts.size() == 2:
			var var_name = parts[0].strip_edges()
			var var_value = parts[1].strip_edges().to_lower()
			
			if i < debugObjList.size():
				var obj = debugObjList[i]
				
				if obj.has("Names") and obj.has("Vars"):
					var index = obj["Names"].find(var_name)
					
					if index != -1:
						var original_value = obj["Vars"][index]  
						var final_value: Variant = original_value
						
						match typeof(original_value):
							TYPE_BOOL:
								if var_value == "true":
									final_value = true
								elif var_value == "false":
									final_value = false
							TYPE_INT:
								if var_value.is_valid_int():
									final_value = var_value.to_int()
							TYPE_FLOAT:
								if var_value.is_valid_float():
									final_value = var_value.to_float()
							TYPE_STRING:
								final_value = var_value

						if typeof(final_value) == typeof(original_value):
							obj["Vars"][index] = final_value
							print("Updated:", var_name, "to", final_value)
						else:
							final_value = original_value
							print("Invalid type for", var_name, "- Resetting to", final_value)
					
						updated_text += "{}: {}\n".format(var_name, str(final_value))

	prompt_txt.text = updated_text.strip_edges()

func _on_area_entered(area: Area2D) -> void:
	print("Debugger detected:", area.name)
	debugObjList.append(area.codable_vars)
	print("Added to debugger:", area.name)
	update_debug_text()

func _on_area_exited(area: Area2D) -> void:
	debugObjList.erase(area.codable_vars)
	update_debug_text()  

func _on_text_changed():
	is_typing = true
	typing_sound.play()

func update_sprite_size():
	if collision_shape.shape is CircleShape2D:
		var radius = collision_shape.shape.radius
		if sprite.texture:
			var texture_size = sprite.texture.get_size().x / 2.0
			sprite.scale = Vector2.ONE * (radius / texture_size)

			sprite.position = collision_shape.position + Vector2(0, -2)


func _on_exit_button_pressed() -> void:
		close_debugger()
		open_debugger_sound.play()
	
