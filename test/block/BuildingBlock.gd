class_name BuildingBlock
extends RigidBody

signal block_deleted

onready var outline : MeshInstance = $Outline
var locked : bool = false

func _ready() -> void:
	gravity_scale = 0

func _on_Block_input_event(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if locked:
		return
	if event.is_action_pressed("delete-block"):
		queue_free()
		emit_signal("block_deleted")

func _on_Block_mouse_entered() -> void:
	outline.visible = not locked


func _on_Block_mouse_exited() -> void:
	outline.visible = false
