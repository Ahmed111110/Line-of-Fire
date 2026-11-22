extends Node3D

var cam: Camera3D
var yaw: float = 0.0
var pitch: float = 0.0
var move_dir: Vector2 = Vector2.ZERO
var drag_id: int = -1
var joy_id: int = -1
var joy_center: Vector2 = Vector2(150, 520)
var knob: Panel
var debug_label: Label

func _ready() -> void:
	_setup_ui()
	_log("Starting Line of Fire...")
	_setup_env()
	_setup_camera()
	_build_castle_and_city()
	_log("Ready! Drag right side to look, left side to move.")

func _log(msg: String) -> void:
	if debug_label != null:
		debug_label.text = msg

func _setup_ui() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)

	debug_label = Label.new()
	debug_label.position = Vector2(20, 20)
	debug_label.size = Vector2(1200, 60)
	debug_label.text = "Booting..."
	hud.add_child(debug_label)

	var base := Panel.new()
	base.position = Vector2(70, 440)
	base.size = Vector2(160, 160)
	var s_base := StyleBoxFlat.new()
	s_base.bg_color = Color(0.15, 0.15, 0.18, 0.65)
	s_base.set_corner_radius_all(80)
	base.add_theme_stylebox_override("panel", s_base)
	hud.add_child(base)

	knob = Panel.new()
	knob.position = Vector2(55, 55)
	knob.size = Vector2(50, 50)
	var s_knob := StyleBoxFlat.new()
	s_knob.bg_color = Color(1.0, 0.85, 0.2, 0.95)
	s_knob.set_corner_radius_all(25)
	knob.add_theme_stylebox_override("panel", s_knob)
	base.add_child(knob)

	var btn_forward := Button.new()
	btn_forward.text = "FORWARD"
	btn_forward.position = Vector2(1040, 430)
	btn_forward.size = Vector2(180, 70)
	btn_forward.button_down.connect(func(): move_dir.y = -1.0)
	btn_forward.button_up.connect(func(): move_dir.y = 0.0)
	hud.add_child(btn_forward)

	var btn_back := Button.new()
	btn_back.text = "BACK"
	btn_back.position = Vector2(1040, 520)
	btn_back.size = Vector2(180, 70)
	btn_back.button_down.connect(func(): move_dir.y = 1.0)
	btn_back.button_up.connect(func(): move_dir.y = 0.0)
	hud.add_child(btn_back)

func _setup_env() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.28, 0.58, 0.88)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 1.5
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.position = Vector3(10, 30, 15)
	sun.look_at(Vector3.ZERO, Vector3.UP)
	sun.light_energy = 1.5
	add_child(sun)

func _setup_camera() -> void:
	cam = Camera3D.new()
	cam.position = Vector3(0.0, 3.0, 15.0)
	cam.fov = 75.0
	add_child(cam)
	cam.make_current()

func _make_box(b_name: String, b_size: Vector3, b_pos: Vector3, b_color: Color) -> void:
	var mi := MeshInstance3D.new()
	mi.name = b_name
	mi.position = b_pos

	var box := BoxMesh.new()
	box.size = b_size
	mi.mesh = box

	var mat := StandardMaterial3D.new()
	mat.albedo_color = b_color
	mat.roughness = 0.8
	mi.material_override = mat

	add_child(mi)

func _build_castle_and_city() -> void:
	# أرضية وسط خانيونس
	_make_box("Ground", Vector3(260.0, 1.0, 260.0), Vector3(0.0, -0.5, 0.0), Color(0.76, 0.65, 0.45))
	# شارع رئيسي
	_make_box("MainRoad", Vector3(12.0, 0.08, 180.0), Vector3(0.0, 0.04, 0.0), Color(0.20, 0.20, 0.22))
	# قلعة خانيونس وأبراجها أمام الكاميرا
	_make_box("CastleMain", Vector3(32.0, 10.0, 24.0), Vector3(0.0, 5.0, -28.0), Color(0.86, 0.70, 0.42))
	_make_box("CastleTowerL", Vector3(8.0, 15.0, 8.0), Vector3(-18.0, 7.5, -18.0), Color(0.75, 0.56, 0.32))
	_make_box("CastleTowerR", Vector3(8.0, 15.0, 8.0), Vector3(18.0, 7.5, -18.0), Color(0.75, 0.56, 0.32))
	# مبانٍ جانبية
	_make_box("BldgL1", Vector3(16.0, 9.0, 14.0), Vector3(-20.0, 4.5, 2.0), Color(0.55, 0.56, 0.60))
	_make_box("BldgR1", Vector3(16.0, 10.0, 14.0), Vector3(20.0, 5.0, 2.0), Color(0.62, 0.58, 0.50))

func _input(event: InputEvent) -> void:
	if cam == null:
		return
	var w := get_viewport().get_visible_rect().size.x
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < w * 0.4 and joy_id == -1:
				joy_id = event.index
			elif event.position.x >= w * 0.4 and drag_id == -1:
				drag_id = event.index
		else:
			if event.index == joy_id:
				joy_id = -1
				move_dir = Vector2.ZERO
				if knob != null:
					knob.position = Vector2(55, 55)
			elif event.index == drag_id:
				drag_id = -1
	elif event is InputEventScreenDrag:
		if event.index == drag_id:
			yaw -= event.relative.x * 0.005
			pitch = clamp(pitch - event.relative.y * 0.005, deg_to_rad(-80), deg_to_rad(80))
			cam.rotation = Vector3(pitch, yaw, 0.0)
		elif event.index == joy_id:
			var rel := (event.position - joy_center).limit_length(55.0)
			move_dir = rel / 55.0
			if knob != null:
				knob.position = Vector2(55, 55) + rel

func _process(delta: float) -> void:
	if cam == null:
		return
	if move_dir.length() > 0.05:
		var fwd := -cam.global_transform.basis.z
		fwd.y = 0.0
		fwd = fwd.normalized()
		var right := cam.global_transform.basis.x
		right.y = 0.0
		right = right.normalized()
		cam.position += (right * move_dir.x - fwd * move_dir.y) * 8.0 * delta
