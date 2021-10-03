class_name PauseMenu
extends Control

signal restart_pressed
signal quit_pressed
signal resume_game_pressed

func _on_Quit_pressed() -> void:
	emit_signal("quit_pressed")

func _on_Restart_pressed() -> void:
	emit_signal("restart_pressed")

func _on_Resume_pressed() -> void:
	emit_signal("resume_game_pressed")
