extends Spatial

var current_block = "line"

onready var ray_ground : RayCast = $RayGround
onready var ray : RayCast = $RayCast
onready var pointer : MeshInstance = $Debug/Pointer
onready var camera : OrbitalCamera = $OrbitalCamera
onready var pause_menu : PauseMenu = $PauseMenu
onready var block_container : Spatial = $Construction
onready var fade : UIFade = $Fade
onready var ui : UI = $UI
onready var game_over : GameOver = $GameOver
onready var crane : Crane = $Crane
var m_position : Vector2 = Vector2.ZERO
var _target : Vector3 = Vector3.ZERO
const CRANE_SPEED : float = 4.0
var wakeup_blocks : bool = false

var playing : bool = false
var is_game_over : bool = false

onready var objective : BuildingPlan

func _ready() -> void:
	if GameData.current_level != null:
		start_level()
	else:
		go_to_main_menu()

func start_level() -> void:
	if objective != null and has_node(objective.get_path()):
		remove_child(objective)
	var level_data = GameData.levels[GameData.current_level]
	objective = load(level_data.path).instance()
	add_child(objective)
	
	for block in block_container.get_children():
		block.queue_free()
	
	objective.connect("objective_updated", self, "_on_Objective_updated")
	objective.connect("objective_completed", self, "_on_Objective_completed")
	objective.make_collision_areas()
	yield(objective, "level_initiated")

	current_block = "tower"
	ui.reset()
	ui.set_type(current_block)
	crane.spawn_block(current_block)
	fade.fade_in("level_start")

func _input(event: InputEvent) -> void:

	if is_game_over:
		pass
	elif playing:
		_handle_game_input(event)
	else:
		_handle_pause_input(event)

func _handle_pause_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		playing = true
		close_pause_menu()

func _handle_game_input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_cancel"):
		open_pause_menu()

	if event is InputEventMouseMotion:
		m_position = event.position

	if event.is_action_pressed("drop-block") and playing:
		if crane.hold_something():
			var block : BuildingBlock = crane.get_current_block()
			var t = block.global_transform
			crane.detach()
			var velocity = crane.chariot_velocity
			block.unlock()
			ui.add_cost(block.price)
			block_container.add_child(block)
			block.apply_central_impulse(velocity * block.mass)
			block.global_transform = t
# warning-ignore:return_value_discarded
			block.connect("block_deleted", self, "_on_Block_deleted")
			$Timer.start()

	if Input.is_action_pressed("alt-action"):
		if event.is_action_pressed("zoom-in"):
			camera.zoom(true)
		if event.is_action_pressed("zoom-out"):
			camera.zoom(false)
	else:
		if event.is_action_pressed("next-block"):
			update_current_block(1)

		if event.is_action_pressed("previous-block"):
			update_current_block(-1)

	if event.is_action_pressed("alt-action"):
		crane.start_rotation(m_position.x)

	if event.is_action_released("alt-action"):
		crane.end_rotation()
		_update_camera_delta_drag(m_position)


func update_current_block(step: int) -> void:
	var i = GameData.available_blocks.find(current_block)
	i = (i + step) % len(GameData.available_blocks)
	current_block = GameData.available_blocks[i]
	ui.set_type(current_block)
	if $Timer.is_stopped():
		crane.spawn_block(current_block)

func _physics_process(delta: float) -> void:
	var is_alt_actions = Input.is_action_pressed("alt-action")
	if not camera.dragging:
		if is_alt_actions:
			crane.update_rotation(m_position.x)
		else:
			var from = camera.project_ray_origin(m_position)
			ray_ground.global_transform.origin = from
			ray_ground.cast_to = from + camera.project_ray_normal(m_position) * 1000
			if ray_ground.is_colliding():
				_target = ray_ground.get_collision_point()
				$Debug/Target.global_transform.origin = _target

	var p0 = ray.global_transform.origin
	var p = lerp(Vector3(p0.x, 80, p0.z), Vector3(_target.x, 80, _target.z), delta * CRANE_SPEED)
	ray.global_transform.origin = p
	if ray.is_colliding():
		pointer.global_transform.origin = ray.get_collision_point()

	if wakeup_blocks:
		_wakeup_blocks()

func _process(delta: float) -> void:
	if playing:
		crane.point_at(ray.global_transform.origin)
		objective.show_objective(Input.is_action_pressed("show-objective"))
		ui.add_time(delta)

func _on_OrbitalCamera_orbiting_end(mouse_position: Vector2) -> void:
	_update_camera_delta_drag(mouse_position)

func _update_camera_delta_drag(mouse_position: Vector2) -> void:
	var _end_drag : Vector2 = camera.unproject_position(_target)
	camera.set_delta_drag(mouse_position - _end_drag)

func _on_OrbitalCamera_orbiting_start() -> void:
	pass

func _on_Block_deleted(_price: int) -> void:
	wakeup_blocks = true

func _wakeup_blocks() -> void:
	wakeup_blocks = false
	for block in block_container.get_children():
		if block is BuildingBlock:
			block.sleeping = false


func _on_Area_body_entered(body: Node) -> void:
	if body is BuildingBlock:
		body.queue_free()

func _on_Timer_timeout() -> void:
	crane.spawn_block(current_block)

func compute_percent_match() -> void:
	ui.set_percent(objective.get_percent() * 100.0)

func _on_Objective_updated(total: int, success: int, _failure: int) -> void:
	ui.set_percent(float(success) / float(total) * 100.0)

func _on_Objective_completed() -> void:
	is_game_over = true
	playing = false
	var percent = objective.get_percent()
	var data = {
		"victory": true,
		"time": ui.time_acc,
		"cost": ui.cost_acc,
		"percent": percent
	}
	game_over.open(data)

func _on_PauseMenu_resume_game_pressed() -> void:
	playing = true
	close_pause_menu()

func _on_PauseMenu_quit_pressed() -> void:
	fade.fade_out("main_menu")

func _on_PauseMenu_restart_pressed() -> void:
	fade.fade_out("reload_level")
	close_pause_menu()

func open_pause_menu() -> void:
	playing = false
	pause_menu.visible = true
	PhysicsServer.set_active(false)
	$Timer.paused = true

func close_pause_menu() -> void:
	PhysicsServer.set_active(true)
	pause_menu.visible = false
	$Timer.paused = false

func _on_Fade_fade_in_completed(data) -> void:
	match data:
		"level_start":
			playing = true

func _on_Fade_fade_out_completed(data) -> void:
	match data:
		"main_menu":
			go_to_main_menu()
		"reload_level":
			get_tree().reload_current_scene()

func go_to_main_menu() -> void:
	get_tree().change_scene("res://test/MainMenu.tscn")

func _on_GameOver_load_level() -> void:
	fade.fade_out("reload_level")

func _on_GameOver_quit_pressed() -> void:
	fade.fade_out("main_menu")
