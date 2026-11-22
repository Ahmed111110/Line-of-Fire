extends CharacterBody3D

@export var walk_speed: float = 6.5
@export var crouch_speed: float = 3.0
@export var jump_velocity: float = 5.0
@export var touch_look_sensitivity: float = 0.005

var head: Node3D
var camera: Camera3D
var gravity: float = 9.8
var is_crouching: bool = false

var look_drag_index: int = -1
var move_drag_index: int = -1
var move_origin: Vector2 = Vector2.ZERO
var move_vector: Vector2 = Vector2.ZERO
var joy_knob: Control

func _ready() -> void:
	head = get_node_or_null("Head")
	if head == null:
		head = Node3D.new()
		head.name = "Head"
		add_child(head)
	head.position = Vector3(0.0, 1.7, 0.0)

	camera = head.get_node_or_null("Camera3D")
	if camera == null:
		camera = Camera3D.new()
		camera.name = "Camera3D"
		head.add_child(camera)
	camera.current = true
	camera.fov = 75.0

	_build_hud()

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)

	var joy_bg := Panel.new()
	joy_bg.position = Vector2(60, 440)
	joy_bg.size = Vector2(180, 180)
	var bg_box := StyleBoxFlat.new()
	bg_box.bg_color = Color(0.1, 0.1, 0.12, 0.5)
	bg_box.set_corner_radius_all(90)
	joy_bg.add_theme_stylebox_override("panel", bg_box)
	layer.add_child(joy_bg)

	joy_knob = Panel.new()
	joy_knob.position = Vector2(60, 60)
	joy_knob.size = Vector2(60, 60)
	var knob_box := StyleBoxFlat.new()
	knob_box.bg_color = Color(0.95, 0.95, 0.95, 0.85)
	knob_box.set_corner_radius_all(30)
	joy_knob.add_theme_stylebox_override("panel", knob_box)
	joy_bg.add_child(joy_knob)

	var btn_jump := Button.new()
	btn_jump.text = "JUMP"
	btn_jump.position = Vector2(1060, 500)
	btn_jump.size = Vector2(160, 80)
	btn_jump.pressed.connect(_on_jump_pressed)
	layer.add_child(btn_jump)

	var btn_crouch := Button.new()
	btn_crouch.text = "CROUCH"
	btn_crouch.position = Vector2(1060, 400)
	btn_crouch.size = Vector2(160, 80)
	btn_crouch.pressed.connect(_on_crouch_pressed)
	layer.add_child(btn_crouch)

	var dot := ColorRect.new()
	dot.color = Color(1.0, 0.2, 0.2, 0.9)
	dot.size = Vector2(8, 8)
	dot.position = Vector2(636, 356)
	layer.add_child(dot)

func _on_jump_pressed() -> void:
	if is_on_floor():
		velocity.y = jump_velocity

func _on_crouch_pressed() -> void:
	is_crouching = not is_crouching

func _input(event: InputEvent) -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var mid_x: float = vp_size.x * 0.45

	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < mid_x and move_drag_index == -1:
				move_drag_index = event.index
				move_origin = event.position
			elif event.position.x >= mid_x and look_drag_index == -1:
				look_drag_index = event.index
		else:
			if event.index == move_drag_index:
				move_drag_index = -1
				move_vector = Vector2.ZERO
				if joy_knob:
					joy_knob.position = Vector2(60, 60)
			elif event.index == look_drag_index:
				look_drag_index = -1

	elif event is InputEventScreenDrag:
		if event.index == look_drag_index and head != null:
			rotate_y(-event.relative.x * touch_look_sensitivity)
			head.rotate_x(-event.relative.y * touch_look_sensitivity)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		elif event.index == move_drag_index:
			var diff: Vector2 = event.position - move_origin
			var limited: Vector2 = diff.limit_length(60.0)
			move_vector = limited / 60.0
			if joy_knob:
				joy_knob.position = Vector2(60, 60) + limited

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if head != null:
		var target_h: float = 1.1 if is_crouching else 1.7
		head.position.y = lerp(head.position.y, target_h, 12.0 * delta)

	var spd: float = crouch_speed if is_crouching else walk_speed
	var dir_3d: Vector3 = (transform.basis * Vector3(move_vector.x, 0.0, move_vector.y)).normalized()

	if dir_3d.length() > 0.01:
		velocity.x = dir_3d.x * spd
		velocity.z = dir_3d.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0.0, spd * delta * 12.0)
		velocity.z = move_toward(velocity.z, 0.0, spd * delta * 12.0)

	move_and_slide()
