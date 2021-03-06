class_name Crane
extends Spatial

onready var arm_pivot : Spatial = $Pivot
onready var chariot : Spatial = $Pivot/Chariot
onready var hook_rt : RemoteTransform = $Pivot/Chariot/Rope/Hook/RemoteTransform
onready var hook : Spatial = $Pivot/Chariot/Rope/Hook
onready var laser : Laser = $Pivot/Chariot/Rope/Hook/Laser
var _building_block : BuildingBlock
var _initial_block_basis : Basis
var chariot_velocity : Vector3 = Vector3.ZERO
var _last_chariot_position := Vector3.ZERO
var _start_rotation_x := 0.0

const ROTATION_BLOCK = 2.0 * PI

func point_at(position: Vector3) -> void:
	var p2 = position
	var x = p2.x
	var z = p2.z
	var y = arm_pivot.global_transform.origin.y
	arm_pivot.look_at(Vector3(x, y, z), Vector3.UP)
	var dist = to_local(Vector3(x, 0, z)).length()
	dist = min(35, max(6, dist))
	chariot.transform.origin = Vector3(0, 0, -dist)

func hold_something() -> bool:
	return _building_block != null and _building_block is BuildingBlock

func spawn_block(block_type: String) -> void:
	if _building_block != null:
		remove_child(_building_block)
		_building_block.queue_free()
	_building_block = GameData.BUILDING_BLOCKS[block_type].instance()
	add_child(_building_block)
	_building_block.lock()
	hook_rt.remote_path = _building_block.get_path()

func get_current_block() -> BuildingBlock:
	return _building_block

func detach() -> void:
	remove_child(_building_block)
	_building_block = null
	hook_rt.remote_path = ""
	end_rotation()

func _process(delta: float) -> void:
	chariot_velocity = (chariot.global_transform.origin - _last_chariot_position) / delta
	_last_chariot_position = chariot.global_transform.origin

func start_rotation(x: float) -> void:
	if not hold_something():
		return
	_start_rotation_x = x
	_initial_block_basis = _building_block.global_transform.basis

func end_rotation() -> void:
	_start_rotation_x = 0.0
	laser.reset()

func update_rotation(x: float) -> void:
	if not hold_something():
		return
	var vp : Vector2 = get_viewport().get_visible_rect().size / 2.0
	var angle : float = ((_start_rotation_x - x) / vp.x) * ROTATION_BLOCK
	var b = _initial_block_basis.rotated(Vector3.UP, -angle)
	_building_block.global_transform.basis = b
	laser.update_rotation(b)
