class_name UIMainMenu
extends Control

signal quit_game_pressed
signal level_selected(level_id)

onready var levels = $MarginContainer/HBoxContainer/Levels
onready var help = $MarginContainer/HBoxContainer/Help
onready var level_list = $MarginContainer/HBoxContainer/Levels/MarginContainer/ColorRect/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

func _ready() -> void:
	levels.visible = false
	help.visible = false
	set_levels_list()

func set_levels_list() -> void:
	GameData.load_save()
	var any_completed = false
	for level_id in GameData.levels:
		var btn = Button.new()
		btn.rect_min_size = Vector2(32, 42)
		var level = GameData.levels[level_id]
		any_completed = any_completed or level.completed

		btn.text = "%s" % [tr(level_id)]
		btn.disabled = not (level.completed or level_id == "lvl1")
		if level.has('title'):
			btn.text = "%s" % [tr(level.title)]

		btn.connect("pressed", self, "_on_Level_selected", [level_id])
		level_list.add_child(btn)


func _on_Quit_pressed() -> void:
	emit_signal("quit_game_pressed")

func _on_Help_pressed() -> void:
	levels.visible = false
	help.visible = true

func _on_Resume_pressed() -> void:
	help.visible = false
	levels.visible = true

func _on_Level_selected(level_id: String) -> void:
	emit_signal("level_selected", level_id)
