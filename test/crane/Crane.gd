class_name Crane
extends Spatial

onready var arm_pivot : Spatial = $Pivot
onready var chariot : Spatial = $Pivot/Chariot
onready var hook : RemoteTransform = $Pivot/Chariot/Rope/Hook/RemoteTransform
var _thing_attached : BuildingBlock
var chariot_velocity : Vector3 = Vector3.ZERO

func point_at(position: Vector3) -> void:
	var p2 = position
	var x = p2.x
	var z = p2.z
	var y = arm_pivot.global_transform.origin.y
	arm_pivot.look_at(Vector3(x, y, z), Vector3.UP)
	var dist = to_local(Vector3(x, 0, z)).length()
	dist = min(80, max(10, dist))
	chariot.transform.origin = Vector3(0, 0, -dist)

func hold_something() -> bool:
	return _thing_attached != null and _thing_attached is BuildingBlock

func detach() -> BuildingBlock:
	hook.remote_path = ""
	var thing = _thing_attached
	_thing_attached = null
	return thing

func attach(something: BuildingBlock) -> void:
	hook.remote_path = something.get_path()
	_thing_attached = something

var _last_chariot_position := Vector3.ZERO

func _process(delta: float) -> void:
	chariot_velocity = (chariot.global_transform.origin - _last_chariot_position) / delta
	_last_chariot_position = chariot.global_transform.origin
