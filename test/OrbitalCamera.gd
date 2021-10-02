class_name OrbitalCamera
extends Spatial

signal orbiting_start()
signal orbiting_end(position)

onready var camera : Camera = $Camera
var dragging : bool = false

var _target_angle : float = 0.0
var _initial_mouse_position : Vector2 = Vector2.ZERO
var _initial_basis : Basis = Basis()
var _drag_delta : Vector2 = Vector2.ZERO

const ORBITAL_ROTATION : float = 1.5 * PI

func _ready() -> void:
	camera.look_at(global_transform.origin, Vector3.UP)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera-drag") and not dragging:
		_start_dragging(event.position)

	if event.is_action_released("camera-drag"):
		_end_dragging(event.position)

	if event is InputEventMouseMotion:
		var delta_p = _initial_mouse_position - (event.position)
		var vp = get_viewport().get_visible_rect().size / 2
		_target_angle = (delta_p.x / vp.x) * ORBITAL_ROTATION

func _start_dragging(event_position: Vector2) -> void:
	dragging = true
	_initial_mouse_position = event_position
	_initial_basis = global_transform.basis
	_target_angle = 0.0
	emit_signal("orbiting_start")

func _end_dragging(event_position: Vector2) -> void:
	dragging = false
	emit_signal("orbiting_end", event_position)

func _process(_delta: float) -> void:
	if dragging:
		global_transform.basis = _initial_basis.rotated(Vector3.UP, _target_angle)

func set_delta_drag(delta: Vector2) -> void:
	_drag_delta = delta

func project_ray_origin(position: Vector2) -> Vector3:
	return camera.project_ray_origin(position - _drag_delta)

func project_ray_normal(position: Vector2) -> Vector3:
	return camera.project_ray_normal(position - _drag_delta)

func unproject_position(position: Vector3) -> Vector2:
	return camera.unproject_position(position)
