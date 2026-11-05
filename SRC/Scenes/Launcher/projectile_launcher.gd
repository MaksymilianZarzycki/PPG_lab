class_name ProjectileLauncher
extends Node3D

@export var colldown: float = 0.5
@export var projectile: PackedScene
@export var parent: Node
@export var spawn_point: Node3D

@onready var cooldown_timer: Timer = $CooldownTimer

var can_shoot: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cooldown_timer.wait_time = colldown
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

func shoot(direction: Vector3):
	if can_shoot:
		can_shoot = false
		var new_projectile: Projectile = projectile.instantiate()
		parent.get_parent().add_child(new_projectile)
		new_projectile.global_position = spawn_point.global_position
		new_projectile.direction = direction
		cooldown_timer.start()

func _on_cooldown_timer_timeout():
	can_shoot = true
