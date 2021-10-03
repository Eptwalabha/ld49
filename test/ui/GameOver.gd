class_name GameOver
extends Control

signal load_level
signal quit_pressed

onready var restart = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Action/Restart
onready var next = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Action/NextLevel
onready var quit = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Action/Quit
onready var title = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Title

var victory := false

func _ready() -> void:
	visible = false

func open(player_data: Dictionary) -> void:
	visible = true
	victory = player_data.victory == true
	next.visible = victory
	title.text = "Victory!" if victory else "Oh no!"
	if victory:
		GameData.unlock_next_level()

func _on_NextLevel_pressed() -> void:
	GameData.next_level()
	emit_signal("load_level")

func _on_Restart_pressed() -> void:
	emit_signal("load_level")

func _on_Quit_pressed() -> void:
	emit_signal("quit_pressed")
