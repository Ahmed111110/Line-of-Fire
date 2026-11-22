extends CharacterBody3D

@export var walk_speed: float = 5.5
@export var sprint_speed: float = 8.5
@export var crouch_speed: float = 2.8
@export var jump_velocity: float = 4.6
@export var mouse_sensitivity: float = 0.0025

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_crouching: bool = false

func _ready() -> void:
	if not has_node("Head"):
		head = Node3D.new()
		head.name = "Head"
		head.position = Vector3(0.0, 1.65, 0.0)
		add_child(head)

		camera = Camera3D.new()
		camera.name = "Camera3D"
		head.add_child(camera)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	is_crouching = Input.is_key_pressed(KEY_C) or Input.is_key_pressed(KEY_CTRL)
	var target_head_y := 1.05 if is_crouching else 1.65
	if head:
		head.position.y = lerp(head.position.y, target_head_y, 12.0 * delta)

	var current_speed := walk_speed
	if is_crouching:
		current_speed = crouch_speed
	elif Input.is_key_pressed(KEY_SHIFT):
		current_speed = sprint_speed

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed * delta * 8.0)
		velocity.z = move_toward(velocity.z, 0.0, current_speed * delta * 8.0)

	move_and_slide()
