extends Spatial

onready var Level = preload("res://test/Block.tscn")
onready var r0 : RayCast = $R0
onready var ray : RayCast = $RayCast
onready var pointer : MeshInstance = $Pointer
onready var camera : Camera = $CameraPivot/Camera
var m_position : Vector2 = Vector2.ZERO

func _ready() -> void:
	camera.look_at($CameraPivot.global_transform.origin, Vector3.UP)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		m_position = event.position
	if event.is_action_pressed("drop-block"):
		var block = Level.instance()
		add_child(block)
		block.global_transform.origin = pointer.global_transform.origin + Vector3(0, 3, 0)

func _physics_process(delta: float) -> void:
	var from = camera.project_ray_origin(m_position)
	var to = from + camera.project_ray_normal(m_position) * 100
	r0.global_transform.origin = from
	r0.cast_to = to
	if r0.is_colliding():
		ray.global_transform.origin = r0.get_collision_point() + Vector3(0, 8, 0)
		if ray.is_colliding():
			pointer.global_transform.origin = ray.get_collision_point()

