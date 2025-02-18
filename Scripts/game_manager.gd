extends Node

var score = 0
@onready var score_label: Label = $ScoreLabel

func add_score():
	score += 100
	score_label.text = "score: " + str(score)
