class_name BulletManager extends Node

const BULLET = preload("uid://c8gr02yl3ckke")

func spawn_bullet(position: Vector2, velocity: Vector2) -> void:
	var bullet = BULLET.instantiate()
	bullet.position = position
	bullet.velocity = velocity
	bullet.rotation = velocity.angle()
	add_child(bullet)
	bullet.start_timeout()
