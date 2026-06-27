class_name HealthComponent extends Node

signal health_changed(old: float, new: float)
signal died(source: Node2D)

@export var max_health := 100.0

var current_health := 0.0

var _parent: Node

func _ready() -> void:
	_parent = get_parent()
	current_health = max_health
	
func damage(amount: float, source: Node2D = null) -> void:
	var old = current_health
	current_health = clamp(current_health - amount, 0.0, max_health)
	_emit(old, source)
	
func heal(amount: float, source: Node2D = null) -> void:
	var old = current_health
	current_health = clamp(current_health + amount, 0.0, max_health)
	_emit(old, source)

func reset():
	var old = current_health
	current_health = max_health
	_emit(old, null)

func set_health(amount: float):
	max_health = amount
	current_health = amount

func _emit(old: float, source: Node2D) -> void:
	health_changed.emit(old, current_health)
	if current_health <= 0.0:
		died.emit()
		
		if _parent.has_method("die"):
			_parent.die(source)
		else:
			_parent.queue_free()
