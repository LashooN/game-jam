class_name Earth extends Area2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite_2d: Sprite2D = $Sprite2D

signal died

func reset():
	visible = true
	health_component.reset()

func die(source):
	visible = false
	Global.world.transition_manager.game_over()
