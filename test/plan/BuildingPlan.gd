class_name BuildingPlan
extends Spatial

signal objective_updated(total, success, failure)
signal area_created

var points : Array = []
var matching_blocks : Array = []
var non_matching_blocks : Array = []
var decimate_points := false
var success_counter : int = 0
var total : int = 0

onready var point_container : Spatial = $Points

const STEP : float = 1.0

func make_collision_areas() -> void:
	if len(points) > 0:
		emit_signal("area_created")
		return

	var bounding_box := AABB()
	bounding_box.position = Vector3(-3, 0, -2)
	bounding_box.size = Vector3(6, 10, 4)

	points = []

	for p in point_container.get_children():
		point_container.remove_child(p)

	var nx = int(bounding_box.size.x / STEP) + 1
	var ny = int(bounding_box.size.y / STEP) + 1
	var nz = int(bounding_box.size.z / STEP) + 1
	for x in range(nx):
		for y in range(ny):
			for z in range(nz):
				var point_area : Area = Area.new()
				point_area.collision_layer = 0
				point_area.collision_mask = 16
				point_area.input_ray_pickable = false
				point_container.add_child(point_area)
				point_area.global_transform.origin = Vector3(x * STEP, y * STEP, z * STEP) + bounding_box.position
				var collision = CollisionShape.new()
				collision.shape = BoxShape.new()
				collision.shape.extents = Vector3(.2, .2, .2)
				point_area.add_child(collision)
				points.push_back(point_area)

	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")

	var matching_points = []
	for point in points:
		var is_colliding = false
		for area in $Areas.get_children():
			if point.overlaps_area(area):
				is_colliding = true
		if is_colliding:
			point.collision_mask = 4
			point.connect("body_entered", self, "_area_body_entered", [point])
			point.connect("body_exited", self, "_area_body_exited", [point])
			matching_points.push_back(point)
		else:
			point_container.remove_child(point)

	points = matching_points
	total = len(points)

	emit_signal("area_created")

func non_colliding_blocks(the_blocks: Array) -> Array:

	var unused = []
	var colliding = []

	for point in points:
		for block in the_blocks:
			if point.overlaps_body(block):
				if colliding.find(block) == -1:
					colliding.push_back(block)

	for block in the_blocks:
		if colliding.find(block) == -1:
			unused.push_back(block)

	return unused

func _area_body_entered(body, _area) -> void:
	if body is BuildingBlock:
		success_counter += 1
		_update_counters()

func _area_body_exited(body, _area) -> void:
	if body is BuildingBlock:
		success_counter -= 1
		_update_counters()

func _update_counters() -> void:
	if total > 0:
		emit_signal("objective_updated", total, success_counter, 0)
