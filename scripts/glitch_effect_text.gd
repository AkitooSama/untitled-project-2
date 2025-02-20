extends Label

@onready var timer = $GlitchTimer

var glitch_texts = [
	"Data Corruption Detected...",
	"Reality is Breaking...",
	"Cannot Escape the System...",
	"Nothing Can Go Wrong...",
]

var ascii_chars = ["#", "%", "@", "*", "!", "?", "&", "$", "█", "▓", "░"]

func _ready():
	timer.wait_time = randf_range(0.1, 0.5)
	timer.start()

func _on_glitch_timer_timeout():
	text = generate_glitch_ascii(glitch_texts[randi() % glitch_texts.size()])
	modulate = Color(1, 1, 1, randf_range(0.4, 1))
	timer.wait_time = randf_range(0.1, 0.5)
	timer.start()

func generate_glitch_ascii(input_text: String) -> String:
	var ascii_output = []
	var max_width = input_text.length() + 4
	
	ascii_output.append("█" + "▓".repeat(max_width) + "█")
	
	var glitch_line = "█ "
	for char in input_text:
		if randf() < 0.2:
			glitch_line += ascii_chars[randi() % ascii_chars.size()]
		else:
			glitch_line += char
	glitch_line += " █"
	ascii_output.append(glitch_line)

	ascii_output.append("█" + "▓".repeat(max_width) + "█")

	if randf() < 0.3:
		ascii_output.insert(1, "█ " + "░".repeat(max_width - 2) + " █")

	return "\n".join(ascii_output)
