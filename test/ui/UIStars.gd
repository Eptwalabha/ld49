class_name UIStars
extends Control

onready var star1 : AnimatedSprite = $CenterContainer/Control/Pivot/Star1
onready var star2 : AnimatedSprite = $CenterContainer/Control/Pivot/Star2
onready var star3 : AnimatedSprite = $CenterContainer/Control/Pivot/Star3

func set_score(score: int) -> void:
	star1.frame = 1 if score > 0 else 0
	star2.frame = 1 if score > 1 else 0
	star3.frame = 1 if score > 2 else 0
