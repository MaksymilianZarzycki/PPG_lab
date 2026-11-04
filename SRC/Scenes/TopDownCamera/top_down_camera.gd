extends Node3D

signal rts_mode_changed(value:bool)
signal rts_target_set(target_pos:Vector3)

@export var speed = 10
@export var ray_length = 50
@export var controlled_character: Node
var rts_mode:bool
@onready var camera_3d: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var debug_point: MeshInstance3D = $DebugPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_camera"):
		rts_mode = !rts_mode
		rts_mode_changed.emit(rts_mode)
		if rts_mode:
			camera_3d.make_current()
			if controlled_character:
				global_position = Vector3(controlled_character.global_position.x,global_position.y,controlled_character.global_position.z)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
			
	if rts_mode:
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		position += Vector3(input_dir.x,0,input_dir.y) * speed * delta
		if Input.is_action_just_pressed("rts_move"):
			ray_cast_3d.target_position = camera_3d.project_local_ray_normal(get_viewport().get_mouse_position()).rotated(Vector3.LEFT,deg_to_rad(90)) * ray_length
			ray_cast_3d.force_raycast_update()
			if ray_cast_3d.is_colliding():
				rts_target_set.emit(ray_cast_3d.get_collision_point())
				debug_point.global_position = ray_cast_3d.get_collision_point()
