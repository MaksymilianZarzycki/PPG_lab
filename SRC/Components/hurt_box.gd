class_name Hurtbox
extends Area3D

signal took_damage(damage: int)

func hit(damage: int):
	took_damage.emit(damage)
