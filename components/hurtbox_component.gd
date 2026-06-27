# HitHurtboxComponent.gd
class_name HurtboxComponent extends Node

@export var damage := 10.0
@export var health_component: HealthComponent
@export var ignore_dmg_col_layer := 0b0
@export var mass := 1.0

signal hurt(damage: float, source: Node2D)
signal collided(source: Node2D)

var _parent: CollisionObject2D

func _ready() -> void:
	_parent = get_parent()
	if _parent.has_signal("area_entered"):
		_parent.area_entered.connect(_handle_collision)
	if _parent.has_signal("body_entered"):
		_parent.body_entered.connect(_handle_collision)
	
	if health_component:
		hurt.connect(health_component.damage)

func _handle_collision(other: CollisionObject2D) -> void:
	var hurtbox := other.get_node_or_null("HurtboxComponent") as HurtboxComponent
	if !hurtbox:
		return
	
	collided.emit(other)
	
	handle_bounce(other, hurtbox)
	
	if (hurtbox._parent.collision_layer & ignore_dmg_col_layer) != 0:
		return

	hurt.emit(hurtbox.damage, other)
	
func handle_bounce(other: CollisionObject2D, hurtbox: HurtboxComponent) -> void:
	if "velocity" not in _parent or "velocity" not in other:
		return

	var normal = (_parent.global_position - other.global_position).normalized()

	var rv = _parent.velocity - other.velocity
	var speed = rv.dot(normal)
	
	if speed > 0:
		return

	var impulse = -speed
	
	var our_mass_perc = mass / (mass + hurtbox.mass)
	var their_mass_perc = hurtbox.mass / (mass + hurtbox.mass)
	
	_parent.velocity += normal * impulse * their_mass_perc

	var correction = normal * 2.0
	_parent.global_position += correction * 0.5 * our_mass_perc
