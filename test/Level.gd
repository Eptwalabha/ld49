extends Spatial

onready var Level = preload("res://test/Block.tscn")
onready var ray_ground : RayCast = $RayGround
onready var ray : RayCast = $RayCast
onready var pointer : MeshInstance = $Debug/Pointer
onready var camera : OrbitalCamera = $OrbitalCamera
var m_position : Vector2 = Vector2.ZERO
var _target : Vector3 = Vector3.ZERO
const CRANE_SPEED : float = 4.0

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		m_position = event.position
	if event.is_action_pressed("drop-block"):
		var block = Level.instance()
		add_child(block)
		block.global_transform.origin = pointer.global_transform.origin + Vector3(0, 3, 0)

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if not camera.dragging:
		update_target_position()
		var from = camera.project_ray_origin(m_position)
		ray_ground.global_transform.origin = from
		ray_ground.cast_to = from + camera.project_ray_normal(m_position) * 100
		if ray_ground.is_colliding():
			_target = ray_ground.get_collision_point()
			$Debug/Target.global_transform.origin = _target
		
	var p0 = ray.global_transform.origin
	var p = lerp(Vector3(p0.x, 8, p0.z), Vector3(_target.x, 8, _target.z), delta * CRANE_SPEED)
	ray.global_transform.origin = p
	if ray.is_colliding():
		pointer.global_transform.origin = ray.get_collision_point()

func update_target_position() -> void:
	pass


func _on_OrbitalCamera_orbiting_end(mouse_position: Vector2) -> void:
	var _end_drag : Vector2 = camera.unproject_position(_target)
	camera.set_delta_drag(mouse_position - _end_drag)

func _on_OrbitalCamera_orbiting_start() -> void:
	pass

