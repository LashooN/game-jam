class_name HealthBar extends ProgressBar

@export var health_component: HealthComponent

func _ready() -> void:
	max_value = health_component.max_health
	value = health_component.current_health
	health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(_old: float, new_value: float) -> void:
	value = new_value
