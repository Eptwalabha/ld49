class_name BuildingBlock
extends RigidBody

signal block_deleted

onready var mesh : MeshInstance = $MeshInstance

func _on_Block_input_event(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("delete-block"):
		queue_free()
		emit_signal("block_deleted")


func _on_Block_mouse_entered() -> void:
	var mat = mesh.get("material/0")
	mat.set("albedo_color", Color(.8, .4, .4, .8))


func _on_Block_mouse_exited() -> void:
	mesh.get("material/0").set("albedo_color", Color(.4, .4, .4, 1))
