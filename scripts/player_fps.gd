extends CharacterBody3D

@export var walk_speed: float = 6.0
@export var crouch_speed: float = 3.0
@export var jump_velocity: float = 4.8
@export var touch_look_sensitivity: float = 0.0045

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_crouching: bool = false
var look_drag_index: int = -1
var move_drag_index: int = -1
var move_origin: Vector2 = Vector2.ZERO
var move_vector: Vector2 = Vector2.ZERO

var joy_base: Panel
var joy_knob: Panel

func _ready() -> void:
	if not has_node("Head"):
		head = Node3D.new()
		head.name = "Head"
		head.position = Vector3(0.0, 1.7, 0.0)
		add_child(head)

		camera = Camera3D.new()
		camera.name = "Camera3D"
		camera.current = true
		head.add_child(camera)

	_create_mobile_controls()

func _create_mobile_controls() -> void:
	var ui := CanvasLayer.new()
	ui.name = "MobileHUD"
	add_child(ui)

	# قاعدة عصا الحركة في أسفل اليسار
	joy_base = Panel.new()
	joy_base.position = Vector2(70, 430)
	joy_base.size = Vector2(170, 170)
	var base_style := StyleBoxFlat.new()
	base_style.bg_color = Color(0.12, 0.14, 0.18, 0.45)
	base_style.corner_radius_top_left = 85
	base_style.corner_radius_top_right = 85
	base_style.corner_radius_bottom_left = 85
	base_style.corner_radius_bottom_right = 85
	joy_base.add_theme_stylebox_override("panel", base_style)
	ui.add_child(joy_base)

	# مقبض عصا الحركة
	joy_knob = Panel.new()
	joy_knob.position = Vector2(55, 55)
	joy_knob.size = Vector2(60, 60)
	var knob_style := StyleBoxFlat.new()
	knob_style.bg_color = Color(0.85, 0.88, 0.92, 0.75)
	knob_style.corner_radius_top_left = 30
	knob_style.corner_radius_top_right = 30
	knob_style.corner_radius_bottom_left = 30
	knob_style.corner_radius_bottom_right = 30
	joy_knob.add_theme_stylebox_override("panel", knob_style)
	joy_base.add_child(joy_knob)

	# زر القفز في أسفل اليمين
	var jump_btn := Button.new()
	jump_btn.text = "قفز"
	jump_btn.position = Vector2(1060, 470)
	jump_btn.size = Vector2(150, 75)
	jump_btn.pressed.connect(_on_jump_pressed)
	ui.add_child(jump_btn)

	# زر الانحناء في أسفل اليمين فوق القفز
	var crouch_btn := Button.new()
	crouch_btn.text = "انحناء"
	crouch_btn.position = Vector2(1060, 375)
	crouch_btn.size = Vector2(150, 75)
	crouch_btn.pressed.connect(_on_crouch_pressed)
	ui.add_child(crouch_btn)

	# نقطة تصويب مركزية خفيفة
	var crosshair := ColorRect.new()
	crosshair.color = Color(1.0, 1.0, 1.0, 0.75)
	crosshair.size = Vector2(6, 6)
	crosshair.position = Vector2(637, 357)
	ui.add_child(crosshair)

func _on_jump_pressed() -> void:
	if is_on_floor():
		velocity.y = jump_velocity

func _on_crouch_pressed() -> void:
	is_crouching = not is_crouching

func _input(event: InputEvent) -> void:
	var screen_w := get_viewport().get_visible_rect().size.x

	if event is InputEventScreenTouch:
		if event.pressed:
			# النصف الأيسر للتحرك، والنصف الأيمن للنظر والالتفاف
			if event.position.x < screen_w * 0.45 and move_drag_index == -1:
				move_drag_index = event.index
				move_origin = event.position
			elif event.position.x >= screen_w * 0.45 and look_drag_index == -1:
				look_drag_index = event.index
		else:
			if event.index == move_drag_index:
				move_drag_index = -1
				move_vector = Vector2.ZERO
				if joy_knob:
					joy_knob.position = Vector2(55, 55)
			elif event.index == look_drag_index:
				look_drag_index = -1

	elif event is InputEventScreenDrag:
		if event.index == look_drag_index:
			rotate_y(-event.relative.x * touch_look_sensitivity)
			head.rotate_x(-event.relative.y * touch_look_sensitivity)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		elif event.index == move_drag_index:
			var delta_pos := event.position - move_origin
			var max_radius := 55.0
			var clamped := delta_pos.limit_length(max_radius)
			move_vector = clamped / max_radius
			if joy_knob:
				joy_knob.position = Vector2(55, 55) + clamped

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var target_head_y := 1.1 if is_crouching else 1.7
	if head:
		head.position.y = lerp(head.position.y, target_head_y, 12.0 * delta)

	var current_speed := crouch_speed if is_crouching else walk_speed

	var key_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var combined_dir := move_vector if move_vector.length() > 0.05 else key_dir

	var direction := (transform.basis * Vector3(combined_dir.x, 0.0, combined_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed * delta * 10.0)
		velocity.z = move_toward(velocity.z, 0.0, current_speed * delta * 10.0)

	move_and_slide()
