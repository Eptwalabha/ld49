class_name BuildingPlan
extends Spatial

signal objective_updated(total, success, failure)
signal objective_completed
signal objective_failed(reason)
signal level_initiated

onready var point_container : Spatial = $Points
onready var objective : Spatial = $Objective

export(AABB) var aabb : AABB = AABB(Vector3(-5, 0, -5), Vector3(10, 10, 10))

export(float, .5, 1.0) var target_complience : float = .8
export(bool) var has_time_limit : bool = false
export(int) var minutes : int = 5
export(int, 0, 59) var secondes : int = 0
var time_limit : float = float(minutes * 60 + secondes)
export(bool) var has_budget_constaint : bool = false
export(int) var budget : int = 5000

export(String) var level_name : String = "level"

var points : Array = []
var matching_blocks : Array = []
var non_matching_blocks : Array = []
var decimate_points := false
var success_counter : int = 0
var failure_counter : int = 0
var total : int = 0

const STEP : float = .5

func _ready() -> void:
	for block in objective.get_children():
		if block is BuildingBlock:
			block.turn_into_objective()
	objective.visible = false
	$Objective/blueprint.visible = true

func make_collision_areas() -> void:
	if len(points) > 0:
		emit_signal("level_initiated")
		return

	points = []

	for p in point_container.get_children():
		point_container.remove_child(p)

	var nx = int(aabb.size.x / STEP) + 1
	var ny = int(aabb.size.y / STEP) + 1
	var nz = int(aabb.size.z / STEP) + 1
	for x in range(nx):
		for y in range(ny):
			for z in range(nz):
				var point_area : Area = Area.new()
				point_area.collision_layer = 0
				point_area.collision_mask = 16
				point_area.input_ray_pickable = false
				point_container.add_child(point_area)
				point_area.global_transform.origin = Vector3(x * STEP, y * STEP, z * STEP) + aabb.position
				var collision = CollisionShape.new()
				collision.shape = BoxShape.new()
				collision.shape.extents = Vector3(.2, .2, .2)
				point_area.add_child(collision)
				points.push_back(point_area)

	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")

	for point in points:
		var is_colliding = false
		for block in objective.get_children():
			if point.overlaps_body(block):
				is_colliding = true
		point.collision_mask = 4
		if is_colliding:
			total += 1
		point.connect("body_entered", self, "_area_body_entered", [is_colliding])
		point.connect("body_exited", self, "_area_body_exited", [is_colliding])

	emit_signal("level_initiated")

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

func _area_body_entered(body, is_success) -> void:
	if body is BuildingBlock:
		if is_success:
			success_counter = int(min(total, success_counter + 1))
		else:
			failure_counter = int(min(total, failure_counter + 1))
		_update_counters()

func _area_body_exited(body, is_success) -> void:
	if body is BuildingBlock:
		if is_success:
			success_counter = int(max(0, success_counter - 1))
		else:
			failure_counter = int(max(0, failure_counter - 1))
		_update_counters()

func _update_counters() -> void:
	if total > 0:
		emit_signal("objective_updated", total, success_counter, failure_counter)
#		if get_percent() > target_complience:
		if get_percent() > 0.1:
			emit_signal("objective_completed")

func show_objective(is_visible: bool) -> void:
	objective.visible = is_visible

func get_percent() -> float:
	return float(success_counter) / float(total)
