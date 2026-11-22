extends Node3D

@export var ground_size: Vector2 = Vector2(260.0, 260.0)
@export var castle_size: Vector3 = Vector3(38.0, 8.0, 38.0)

func _ready() -> void:
	_build_ground()
	_build_castle_block()
	_build_surrounding_blocks()

func _build_ground() -> void:
	var ground := StaticBody3D.new()
	ground.name = "Ground"
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(ground_size.x, 1.0, ground_size.y)
	mesh_instance.mesh = box

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.56, 0.50, 0.40)
	mat.roughness = 0.9
	mesh_instance.material_override = mat

	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(ground_size.x, 1.0, ground_size.y)
	shape.shape = box_shape

	ground.position = Vector3(0.0, -0.5, 0.0)
	ground.add_child(mesh_instance)
	ground.add_child(shape)
	add_child(ground)

func _build_castle_block() -> void:
	var castle := StaticBody3D.new()
	castle.name = "KhanYunisCastle"
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = castle_size
	mesh_instance.mesh = box

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.62, 0.54, 0.42)
	mat.roughness = 0.85
	mesh_instance.material_override = mat

	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = castle_size
	shape.shape = box_shape

	castle.position = Vector3(0.0, castle_size.y * 0.5, -35.0)
	castle.add_child(mesh_instance)
	castle.add_child(shape)
	add_child(castle)

func _build_surrounding_blocks() -> void:
	var positions := [
		Vector3(-48.0, 5.0, -10.0),
		Vector3(48.0, 5.0, -10.0),
		Vector3(-42.0, 4.5, 32.0),
		Vector3(42.0, 4.5, 32.0),
		Vector3(0.0, 4.0, 46.0)
	]
	for i in range(positions.size()):
		var b := StaticBody3D.new()
		b.name = "UrbanBlock_%d" % i
		var size := Vector3(22.0, 9.0, 18.0)

		var mesh_instance := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = size
		mesh_instance.mesh = box

		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.45, 0.45, 0.47)
		mat.roughness = 0.8
		mesh_instance.material_override = mat

		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape

		b.position = positions[i]
		b.add_child(mesh_instance)
		b.add_child(shape)
		add_child(b)
