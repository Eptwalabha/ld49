extends Spatial

onready var ui : UIMainMenu = $UI

func _ready() -> void:
	$Fade.fade_in("start")

func _process(delta: float) -> void:
	$Pivot.rotate(Vector3.UP, delta)

func _on_UI_quit_game_pressed() -> void:
	$Fade.fade_out("quit_game")

func _on_UI_level_selected(level_id) -> void:
	GameData.current_level = level_id
	$Fade.fade_out("load_game")

func _on_Fade_fade_in_completed(_data) -> void:
	pass # Replace with function body.

func _on_Fade_fade_out_completed(data) -> void:
	match data:
		"quit_game":
			GameData.save()
			get_tree().quit(0)
		"load_game":
			GameData.reload_attempt = 0
			get_tree().change_scene("res://test/Level.tscn")
