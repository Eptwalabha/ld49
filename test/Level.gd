extends Spatial

var current_block = "line"

onready var ray_ground : RayCast = $RayGround
onready var ray : RayCast = $RayCast
onready var pointer : MeshInstance = $Debug/Pointer
onready var camera : OrbitalCamera = $OrbitalCamera
onready var crane : Crane = $Crane
var m_position : Vector2 = Vector2.ZERO
var _target : Vector3 = Vector3.ZERO
const CRANE_SPEED : float = 4.0
var wakeup_blocks : bool = false

func _ready() -> void:
	$Label.text = current_block

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		m_position = event.position
	if event.is_action_pressed("drop-block"):
		var block = GameData.BUILDING_BLOCKS[current_block].instance()
		$Construction.add_child(block)
		block.connect("block_deleted", self, "_on_Block_deleted")
		block.global_transform.origin = pointer.global_transform.origin + Vector3(0, 3, 0)
	
	if event.is_action_pressed("next-block"):
		update_current_block(1)

	if event.is_action_pressed("previous-block"):
		update_current_block(-1)

func update_current_block(step: int) -> void:
	var i = GameData.available_blocks.find(current_block)
	i = (i + step) % len(GameData.available_blocks)
	current_block = GameData.available_blocks[i]
	$Label.text = current_block


func _physics_process(delta: float) -> void:
	if not camera.dragging:
		var from = camera.project_ray_origin(m_position)
		ray_ground.global_transform.origin = from
		ray_ground.cast_to = from + camera.project_ray_normal(m_position) * 1000
		if ray_ground.is_colliding():
			_target = ray_ground.get_collision_point()
			$Debug/Target.global_transform.origin = _target

	var p0 = ray.global_transform.origin
	var p = lerp(Vector3(p0.x, 8, p0.z), Vector3(_target.x, 8, _target.z), delta * CRANE_SPEED)
	ray.global_transform.origin = p
	if ray.is_colliding():
		pointer.global_transform.origin = ray.get_collision_point()
	
	if wakeup_blocks:
		_wakeup_blocks()

func _process(_delta: float) -> void:
	crane.point_at(ray.global_transform.origin)

func _on_OrbitalCamera_orbiting_end(mouse_position: Vector2) -> void:
	var _end_drag : Vector2 = camera.unproject_position(_target)
	camera.set_delta_drag(mouse_position - _end_drag)

func _on_OrbitalCamera_orbiting_start() -> void:
	pass

func _on_Block_deleted() -> void:
	wakeup_blocks = true

func _wakeup_blocks() -> void:
	wakeup_blocks = false
	for block in $Construction.get_children():
		if block is BuildingBlock:
			block.sleeping = false


func _on_Area_body_entered(body: Node) -> void:
	if body is BuildingBlock:
		body.queue_free()
