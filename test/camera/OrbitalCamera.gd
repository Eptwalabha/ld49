class_name OrbitalCamera
extends Spatial

signal orbiting_start()
signal orbiting_end(position)

onready var camera : Camera = $Pitch/Camera
onready var pitch : Spatial = $Pitch

export(float) var min_zoom := 20.0
export(float) var max_zoom := 200.0
export(float) var zoom_step := 10.0
var _target_zoom : Vector3 = Vector3.ZERO

var dragging : bool = false

var _target_angle : Vector2 = Vector2.ZERO
var _initial_mouse_position : Vector2 = Vector2.ZERO
var _initial_x_basis : Basis = Basis()
var _initial_y_basis : Basis = Basis()
var _drag_delta : Vector2 = Vector2.ZERO

const ORBITAL_ROTATION_X : float = 1.5 * PI
const ORBITAL_ROTATION_Y : float = .5 * PI

func _ready() -> void:
	_target_zoom = camera.global_transform.origin
	camera.look_at(global_transform.origin, Vector3.UP)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera-drag") and not dragging:
		_start_dragging(event.position)

	if event.is_action_released("camera-drag"):
		_end_dragging(event.position)

	if dragging and event is InputEventMouseMotion:
		var delta_p = _initial_mouse_position - (event.position)
		var vp = get_viewport().get_visible_rect().size / 2
		var ratio : Vector2 = delta_p / vp
		var tx = ratio.x * ORBITAL_ROTATION_X
		var ty = ratio.y * ORBITAL_ROTATION_Y
		_target_angle = Vector2(tx, ty)

	if event.is_action_pressed("zoom-in"):
		var dist = camera.transform.origin.length()
		dist = max(min_zoom, dist - zoom_step)
		_target_zoom = camera.transform.origin.direction_to(Vector3.ZERO).normalized() * -dist

	if event.is_action_pressed("zoom-out"):
		var dist = camera.transform.origin.length()
		dist = min(max_zoom, dist + zoom_step)
		_target_zoom = camera.transform.origin.direction_to(Vector3.ZERO).normalized() * -dist

func _start_dragging(event_position: Vector2) -> void:
	dragging = true
	_initial_mouse_position = event_position
	_initial_x_basis = global_transform.basis
	_initial_y_basis = pitch.transform.basis
	_target_angle = Vector2.ZERO
	emit_signal("orbiting_start")

func _end_dragging(event_position: Vector2) -> void:
	dragging = false
	emit_signal("orbiting_end", event_position)

func _process(delta: float) -> void:
	if dragging:
		global_transform.basis = _initial_x_basis.rotated(Vector3.UP, _target_angle.x)
		pitch.transform.basis = _initial_y_basis.rotated(Vector3.FORWARD, _target_angle.y)
		pitch.rotation_degrees.z = clamp(pitch.rotation_degrees.z, -30, 30)
	camera.transform.origin = lerp(camera.transform.origin, _target_zoom, delta * 6.0)

func set_delta_drag(delta: Vector2) -> void:
	_drag_delta = delta

func project_ray_origin(position: Vector2) -> Vector3:
	return camera.project_ray_origin(position - _drag_delta)

func project_ray_normal(position: Vector2) -> Vector3:
	return camera.project_ray_normal(position - _drag_delta)

func unproject_position(position: Vector3) -> Vector2:
	return camera.unproject_position(position)
