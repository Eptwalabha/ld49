class_name BlockPreview
extends Spatial

onready var pivot : Spatial = $Pivot
onready var camera : Camera = $Camera
onready var current_block : BuildingBlock = $Pivot/CurrentBlock

func _ready() -> void:
	camera.look_at(Vector3.ZERO, Vector3.UP)

func change_block(block: BuildingBlock) -> void:
	if current_block != null:
		pivot.remove_child(current_block)
		current_block.queue_free()
	pivot.add_child(block)
	current_block = block

func _process(delta: float) -> void:
	pivot.rotate_y(delta)
