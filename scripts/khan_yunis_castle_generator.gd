extends Node3D

func _ready() -> void:
	_setup_sky_and_environment()
	_build_ground_and_roads()
	_build_castle_complex()
	_build_surrounding_city_blocks()

func _setup_sky_and_environment() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.22, 0.48, 0.82)
	sky_mat.sky_horizon_color = Color(0.75, 0.84, 0.92)
	sky_mat.ground_bottom_color = Color(0.42, 0.36, 0.28)
	sky_mat.ground_horizon_color = Color(0.68, 0.62, 0.52)
	sky.sky_material = sky_mat
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.1
	env_node.environment = env
	add_child(env_node)

func _create_box(node_name: String, size: Vector3, pos: Vector3, color: Color, roughness: float = 0.85) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos

	var mesh_inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_inst.mesh = box

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mesh_inst.material_override = mat

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape

	body.add_child(mesh_inst)
	body.add_child(col)
	add_child(body)

func _build_ground_and_roads() -> void:
	# أرضية وسط خانيونس
	_create_box("Ground", Vector3(300.0, 1.0, 300.0), Vector3(0.0, -0.5, 0.0), Color(0.66, 0.58, 0.45), 0.92)
	# شارع رئيسي يمتد أمام القلعة
	_create_box("MainRoad", Vector3(14.0, 0.08, 220.0), Vector3(0.0, 0.04, 10.0), Color(0.24, 0.25, 0.27), 0.88)
	# شارع عرضي يقطع المحور
	_create_box("CrossStreet", Vector3(220.0, 0.08, 12.0), Vector3(0.0, 0.04, 15.0), Color(0.26, 0.27, 0.29), 0.88)

func _build_castle_complex() -> void:
	# ساحة القلعة الأمامية وموقع القلعة في الاتجاه الأمامي (-Z)
	var cz := -42.0
	# الجدار الخلفي للقلعة
	_create_box("Castle_BackWall", Vector3(44.0, 9.0, 3.0), Vector3(0.0, 4.5, cz - 18.0), Color(0.76, 0.64, 0.46))
	# الجدار الأيسر للقلعة
	_create_box("Castle_LeftWall", Vector3(3.0, 9.0, 36.0), Vector3(-20.5, 4.5, cz), Color(0.74, 0.62, 0.44))
	# الجدار الأيمن للقلعة
	_create_box("Castle_RightWall", Vector3(3.0, 9.0, 36.0), Vector3(20.5, 4.5, cz), Color(0.74, 0.62, 0.44))
	# الجدار الأمامي يسار البوابة
	_create_box("Castle_FrontLeft", Vector3(16.0, 9.0, 3.0), Vector3(-12.5, 4.5, cz + 18.0), Color(0.78, 0.66, 0.48))
	# الجدار الأمامي يمين البوابة
	_create_box("Castle_FrontRight", Vector3(16.0, 9.0, 3.0), Vector3(12.5, 4.5, cz + 18.0), Color(0.78, 0.66, 0.48))
	# عتبة البوابة العلوية للقلعة
	_create_box("Castle_GateArch", Vector3(9.0, 3.0, 3.2), Vector3(0.0, 7.5, cz + 18.0), Color(0.68, 0.56, 0.39))

	# 4 أبراج زاوية للقلعة
	_create_box("Castle_Tower_NW", Vector3(7.5, 13.0, 7.5), Vector3(-21.0, 6.5, cz - 18.0), Color(0.70, 0.58, 0.41))
	_create_box("Castle_Tower_NE", Vector3(7.5, 13.0, 7.5), Vector3(21.0, 6.5, cz - 18.0), Color(0.70, 0.58, 0.41))
	_create_box("Castle_Tower_SW", Vector3(7.5, 13.0, 7.5), Vector3(-21.0, 6.5, cz + 18.0), Color(0.70, 0.58, 0.41))
	_create_box("Castle_Tower_SE", Vector3(7.5, 13.0, 7.5), Vector3(21.0, 6.5, cz + 18.0), Color(0.70, 0.58, 0.41))

	# سواتر تكتيكية في ساحة القلعة
	_create_box("Cover_1", Vector3(5.0, 1.3, 1.4), Vector3(-6.0, 0.65, -14.0), Color(0.55, 0.50, 0.42))
	_create_box("Cover_2", Vector3(5.0, 1.3, 1.4), Vector3(6.5, 0.65, -10.0), Color(0.55, 0.50, 0.42))

func _build_surrounding_city_blocks() -> void:
	# مبانٍ وحارات حول القلعة والشارع الرئيسي
	_create_box("Building_West1", Vector3(20.0, 10.0, 16.0), Vector3(-24.0, 5.0, -4.0), Color(0.52, 0.53, 0.56))
	_create_box("Building_East1", Vector3(20.0, 11.0, 16.0), Vector3(24.0, 5.5, -4.0), Color(0.56, 0.54, 0.50))
	_create_box("Building_West2", Vector3(18.0, 9.0, 18.0), Vector3(-24.0, 4.5, 28.0), Color(0.48, 0.50, 0.53))
	_create_box("Building_East2", Vector3(18.0, 12.0, 18.0), Vector3(24.0, 6.0, 28.0), Color(0.54, 0.52, 0.49))
	_create_box("Building_SouthLeft", Vector3(16.0, 8.5, 14.0), Vector3(-18.0, 4.25, 52.0), Color(0.50, 0.51, 0.54))
	_create_box("Building_SouthRight", Vector3(16.0, 9.5, 14.0), Vector3(18.0, 4.75, 52.0), Color(0.55, 0.53, 0.50))
