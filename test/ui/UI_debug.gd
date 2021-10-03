class_name UI_debug
extends Control

signal check_clicked

onready var type_label : Label = $MarginContainer/HBoxContainer/Label
onready var check_button : Button = $MarginContainer/HBoxContainer/VBoxContainer/Button
onready var check_percent : Label = $MarginContainer/HBoxContainer/VBoxContainer/Percent

func set_type(type: String) -> void:
	type_label.text = type

func set_percent(percent: float) -> void:
	check_percent.text = "%s%%" % percent

func _on_Button_pressed() -> void:
	emit_signal("check_clicked")
