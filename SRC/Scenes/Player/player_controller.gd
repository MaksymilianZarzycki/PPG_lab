extends CharacterBody3D


@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.01
#@export_group("Nodes")

@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var ground_ray: RayCast3D = $GroundRay

@onready var model: Node3D = $AnimationLibrary_Godot_Standard
@onready var animation_player: AnimationPlayer = $AnimationLibrary_Godot_Standard/AnimationPlayer


var original_collider_height : float;

@export_group("RTS movement")
var rts_mode:bool
var rts_move_target:Vector3
@export var target_distance:float

func _ready() -> void:
	camera_3d.make_current()
	original_collider_height = collision_shape_3d.shape.height
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_player.play("Idle")

func _physics_process(delta: float) -> void:
	
	if rts_mode:
		rts_movement(delta)
	else:
		movement(delta)
	move_and_slide()
	

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	if event.is_action_pressed("camera_zoom_in"):
		camera_3d.position.z -= 1
	if event.is_action_pressed("camera_zoom_out"):
		camera_3d.position.z += 1
	camera_3d.position.z = clampf(camera_3d.position.z, 1.0, 10.0)
	
func movement(delta:float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("crouch"):
		collision_shape_3d.shape.height = original_collider_height / 2
		model.position.y = 0.5
		if ground_ray.is_colliding():
			velocity.y = -10
	if Input.is_action_just_released("crouch"):
		collision_shape_3d.shape.height = original_collider_height
		model.position.y = 0
		

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	#Animations
	if not is_on_floor():
		if Input.is_action_pressed("crouch"):
			animation_player.play("Crouch_Idle")
		else:
			animation_player.play("Jump")
	elif input_dir:
		if Input.is_action_pressed("crouch"):
			animation_player.play("Crouch_Fwd")
		else:
			animation_player.play("Sprint")
	else:
		if Input.is_action_pressed("crouch"):
			animation_player.play("Crouch_Idle")
		else:
			animation_player.play("Idle")

func rts_movement(delta:float) -> void:
	var look_dir:Vector3 = global_position.direction_to(rts_move_target)
	var look_angle:float = -Vector2(look_dir.x,look_dir.z).rotated(deg_to_rad(90)).angle()
	
	if global_position.distance_to(rts_move_target) >= target_distance:
		rotation.y = look_angle
		velocity = look_dir * speed
		animation_player.play("Sprint")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		animation_player.play("Idle")

func on_rts_mode_change(value:bool):
	rts_mode = value
	rts_move_target = global_position
	if !rts_mode:
		camera_3d.make_current()
func on_rts_target_set(target_pos:Vector3):
	rts_move_target = target_pos
