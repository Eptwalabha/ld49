class_name Crane
extends Spatial

onready var arm_pivot : Spatial = $Pivot
onready var chariot : Spatial = $Pivot/Chariot

func point_at(position: Vector3) -> void:
	var p2 = position
	var x = p2.x
	var z = p2.z
	var y = arm_pivot.global_transform.origin.y
	arm_pivot.look_at(Vector3(x, y, z), Vector3.UP)
	var dist = to_local(Vector3(x, 0, z)).length()
	dist = min(8, max(1, dist))
	chariot.transform.origin = Vector3(0, 0, -dist)