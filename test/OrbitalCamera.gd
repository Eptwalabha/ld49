class_name OrbitalCamera
extends Spatial

onready var camera : Camera = $Camera
var dragging : bool = false

var _target_angle : float = 0.0
var _initial_mouse_position : Vector2 = Vector2.ZERO
var _initial_basis : Basis = Basis()

const ORBITAL_ROTATION : float = 1.5 * PI

func _ready() -> void:
	camera.look_at(global_transform.origin, Vector3.UP)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera-drag") and not dragging:
		dragging = true
		_initial_mouse_position = event.position
		_initial_basis = global_transform.basis
		_target_angle = 0.0

	if event.is_action_released("camera-drag"):
		dragging = false

	if event is InputEventMouseMotion:
		var delta_p = _initial_mouse_position - event.position
		var vp = get_viewport().get_visible_rect().size / 2
		_target_angle = (delta_p.x / vp.x) * ORBITAL_ROTATION

func _process(delta: float) -> void:
	if dragging:
		global_transform.basis = _initial_basis.rotated(Vector3.UP, _target_angle)
