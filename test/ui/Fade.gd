class_name UIFade

extends ColorRect

signal fade_in_completed(data)
signal fade_out_completed(data)

onready var animation = $AnimationPlayer

var data_callback

func black() -> void:
	visible = true
	color.a = 0.0

func fade_in(data) -> void:
	data_callback = data
	animation.play("in")

func fade_out(data) -> void:
	data_callback = data
	animation.play("out")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"in":
			emit_signal("fade_in_completed", data_callback)
		"out":
			emit_signal("fade_out_completed", data_callback)
