class_name Laser
extends Spatial

onready var ray : RayCast = $RayCast
onready var ray_ground : RayCast = $RayGround
onready var marker : Spatial = $GroundMarker
onready var pivot : Spatial = $Pivot
onready var mesh : Mesh = $Pivot/MeshInstance.mesh

func _physics_process(delta: float) -> void:
	if ray.is_colliding():
		var point = to_local(ray.get_collision_point())
		mesh.size.y = -point.y
		pivot.scale.y = -point.y
	else:
		mesh.size.y = 200
		pivot.scale.y = 200
	
	if ray_ground.is_colliding():
		marker.visible = true
		marker.global_transform.origin = ray_ground.get_collision_point()
	else:
		marker.visible = false

func _process(delta: float) -> void:
	marker.rotate_y(delta * .1)
