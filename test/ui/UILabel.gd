class_name UILabel
extends Control

onready var label = $MarginContainer/HBoxContainer/Label

func set_text(text: String) -> void:
	label.text = text
