class_name Bullet extends Area2D

@onready var gravity_component: GravityComponent = $GravityComponent
@onready var col: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent

@onready var timeout: Timer = $Timeout

var _col_velocity := Vector2.ZERO

var velocity: Vector2:
	get:
		return %GravityComponent.velocity
	set(value):
		%GravityComponent.velocity = value

func _process(delta):
	rotation = velocity.angle()

func start_timeout():
	timeout.start()

func _ready():
	hurtbox_component.collided.connect(_on_collision)
	
	timeout.timeout.connect(_on_timeout)
	
func _on_collision(a):
	_col_velocity = velocity
	
func get_col_velocity() -> Vector2:
	return _col_velocity if _col_velocity != Vector2.ZERO else velocity

func _on_timeout():
	queue_free()
