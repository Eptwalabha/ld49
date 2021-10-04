class_name GameOver
extends Control

signal load_level
signal quit_pressed

onready var restart = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Action/HBoxContainer/Restart
onready var next = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Action/NextLevel
onready var quit = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Action/HBoxContainer/Quit
onready var title = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Title

onready var conformity_line : UIGameOverLine = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Success/HBoxContainer/Conformity
onready var time_line : UIGameOverLine = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Success/HBoxContainer/Time
onready var cost_line : UIGameOverLine = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Success/HBoxContainer/Cost

onready var stars : UIStars = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Success/UIStars
onready var success = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Success
onready var failure = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Failure
onready var failure_label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/Failure/Label

var victory := false

func _ready() -> void:
	visible = false

func open(player_data: Dictionary) -> void:
	visible = true
	victory = player_data.victory == true
	success.visible = victory
	failure.visible = success.visible
	
	if victory:
		set_victory(player_data)
	else:
		set_failure(player_data)
	
	if victory:
		GameData.unlock_next_level()

func set_victory(data) -> void:
	title.text = "Victory!"
	next.visible = true
	stars.set_score(data.score)
	var percent : float = int(data.percent * 1000) / 10.0
	conformity_line.set_text("%s %%" % percent)
	var minutes = int(data.time / 60)
	var secondes = int(data.time) % 60
	time_line.set_text("%02d:%02d" % [minutes, secondes])
	cost_line.set_text("%s" % data.cost)

func set_failure(data) -> void:
	title.text = "Oh no!"
	failure_label.text = data.reason

func _on_NextLevel_pressed() -> void:
	GameData.next_level()
	emit_signal("load_level")

func _on_Restart_pressed() -> void:
	emit_signal("load_level")

func _on_Quit_pressed() -> void:
	emit_signal("quit_pressed")
