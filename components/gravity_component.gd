class_name GravityComponent
extends Node

@export var gm_scale := 1.0


signal external_impulse_applied

var velocity: Vector2 = Vector2.ZERO
var _parent: Node2D

var GM = Consts.GM * gm_scale

func _ready():
	_parent = get_parent()
	GM = Consts.GM * gm_scale
	
func apply_stable_orbit():
	var r = _parent.global_position.length()
	var speed = sqrt(GM / max(r, 1.0))
	velocity = _parent.global_position.normalized().orthogonal() * speed

func _physics_process(delta):
	var sim = Physics.sim_step(_parent.global_position, velocity, delta, GM)
 
	velocity = sim["vel"]
	_parent.global_position = sim["pos"]

func apply_impulse(impulse: Vector2):
	velocity += impulse
	external_impulse_applied.emit()
	
func override_velocity(new_velocity: Vector2):
	velocity = new_velocity
	external_impulse_applied.emit()
	
