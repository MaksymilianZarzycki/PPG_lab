class_name Projectile
extends Node3D

@export var damage: int
@export var initial_force: float

@export var hitbox: Area3D

var direction: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox.area_entered.connect(_on_area_enter)
	hitbox.body_entered.connect(_on_body_enter)

func _physics_process(delta: float) -> void:
	position += direction * initial_force * delta

func _on_area_enter(area: Area3D):
	if area is Hurtbox:
		(area as Hurtbox).hit(damage)
		queue_free()

func _on_body_enter(body: Node3D):
		if (body as CollisionObject3D).collision_layer == 1:
			queue_free()
