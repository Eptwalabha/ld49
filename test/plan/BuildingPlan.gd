class_name BuildingPlan
extends Spatial

signal compute_completed(matching, total, unused)
signal area_created

var points : Array = []
var matching_blocks : Array = []
var non_matching_blocks : Array = []
var decimate_points := false
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
				var point_area = Area.new()
				point_area.collision_layer = 16
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
			matching_points.push_back(point)
		else:
			point_container.remove_child(point)

	points = matching_points
	emit_signal("area_created")

func compute_percent(the_blocks: Array) -> void:
	var total = len(points)
	if total == 0:
		return

	$Areas.transform.origin = Vector3.ZERO

	for point in points:
		point.collision_layer = 4
		point.collision_mask = 4

	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")

	matching_blocks = []
	non_matching_blocks = []
	var matching = 0

	for point in points:
		if not point is Area:
			continue

		var match_block = false
		for block in the_blocks:
			if point.overlaps_body(block):
				match_block = true
				if matching_blocks.find(block) == -1:
					matching_blocks.push_back(block)
		if match_block:
			matching += 1

	for block in the_blocks:
		if matching_blocks.find(block) == -1:
			non_matching_blocks.push_back(block)

	emit_signal("compute_completed", matching, total, non_matching_blocks)
