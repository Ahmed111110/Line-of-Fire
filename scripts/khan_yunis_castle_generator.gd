extends Node3D

func _ready() -> void:
	_setup_env()
	_build_world()

func _setup_env() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.35, 0.62, 0.88)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.95, 0.92, 0.85)
	env.ambient_light_energy = 1.2
	we.environment = env
	add_child(we)

func _make_box(b_name: String, b_size: Vector3, b_pos: Vector3, b_color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = b_name
	body.position = b_pos

	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = b_size
	mi.mesh = box

	var mat := StandardMaterial3D.new()
	mat.albedo_color = b_color
	mat.roughness = 0.85
	mi.material_override = mat

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = b_size
	col.shape = shape

	body.add_child(mi)
	body.add_child(col)
	add_child(body)

func _build_world() -> void:
	# الأرضية
	_make_box("Ground", Vector3(300.0, 2.0, 300.0), Vector3(0.0, -1.0, 0.0), Color(0.72, 0.62, 0.45))

	# الطريق أمام اللاعب باتجاه الشمال (-Z) حيث تقع القلعة
	_make_box("RoadMain", Vector3(14.0, 0.1, 200.0), Vector3(0.0, 0.05, 0.0), Color(0.22, 0.22, 0.24))

	# مجسم القلعة الرئيسي وأبراجها بوضوح أمام اللاعب عند z = -35
	_make_box("CastleCenter", Vector3(34.0, 10.0, 28.0), Vector3(0.0, 5.0, -35.0), Color(0.82, 0.68, 0.44))
	_make_box("TowerLeft", Vector3(8.0, 15.0, 8.0), Vector3(-19.0, 7.5, -23.0), Color(0.74, 0.58, 0.36))
	_make_box("TowerRight", Vector3(8.0, 15.0, 8.0), Vector3(19.0, 7.5, -23.0), Color(0.74, 0.58, 0.36))

	# مبانٍ جانبية حول الطريق
	_make_box("BldgLeft1", Vector3(18.0, 9.0, 16.0), Vector3(-22.0, 4.5, -2.0), Color(0.55, 0.55, 0.58))
	_make_box("BldgRight1", Vector3(18.0, 10.0, 16.0), Vector3(22.0, 5.0, -2.0), Color(0.60, 0.57, 0.50))
	_make_box("BldgLeft2", Vector3(18.0, 8.0, 16.0), Vector3(-22.0, 4.0, 24.0), Color(0.50, 0.52, 0.55))
	_make_box("BldgRight2", Vector3(18.0, 11.0, 16.0), Vector3(22.0, 5.5, 24.0), Color(0.58, 0.55, 0.48))
