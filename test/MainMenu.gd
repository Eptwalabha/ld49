extends Spatial

onready var ui : UIMainMenu = $UI

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	$Pivot.rotate(Vector3.UP, delta)

func _on_UI_quit_game_pressed() -> void:
	get_tree().quit(0)

func _on_UI_level_selected(level_id) -> void:
	GameData.current_level = level_id
	get_tree().change_scene("res://test/Level.tscn")
