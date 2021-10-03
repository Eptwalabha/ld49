class_name UI
extends Control

onready var check_percent : UILabel = $MarginContainer/HBoxContainer/Percentage
onready var cost : UILabel = $MarginContainer/HBoxContainer/VBoxContainer/UICostLabel
onready var block_preview : UIBlockPreview = $MarginContainer/HBoxContainer/VBoxContainer/UIBlockPreview
onready var time : UILabel = $MarginContainer/HBoxContainer/VBoxContainer/Time

var time_acc : float = 0.0
var cost_acc : int = 0

func reset() -> void:
	time_acc = 0.0
	cost_acc = 0
	cost.set_text("0")
	time.set_text("00:00")

func add_cost(amount: int) -> void:
	cost_acc += amount
	cost.set_text("%s" % cost_acc)

func set_type(type: String) -> void:
	block_preview.change_block_type(type)

func set_percent(percent: float) -> void:
	var p = int(percent * 10)
	check_percent.set_text("%s%%" % (float(p) / 10.0))

func add_time(delta: float) -> void:
	time_acc += delta
	var minutes = int(time_acc / 60)
	var secondes = int(time_acc) % 60
	time.set_text("%02d:%02d" % [minutes, secondes])

