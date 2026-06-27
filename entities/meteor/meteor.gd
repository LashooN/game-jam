extends Area2D

@onready var screen_notifier: VisibleOnScreenNotifier2D = $ScreenNotifier

@onready var polygon: Polygon2D = $Polygon2D
@onready var col: CollisionShape2D = $CollisionShape2D

@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var gravity_component: GravityComponent = %GravityComponent
@onready var health_component: HealthComponent = $HealthComponent

const METEOR_SHADER = preload("uid://b2c4tao1rmrcv")

var traj: Trajectory

var type_data := Consts.METEOR_DATA[Consts.MeteorType.CHONDRITE]
var size := 1.0

var our_seed = randf()
var cracked = false
var points

var velocity: Vector2:
	get:
		return %GravityComponent.velocity
	set(value):
		%GravityComponent.override_velocity(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !points:
		points = Global.generate_meteor_points(type_data.type, size)
	polygon.polygon = points
	
	var mat = ShaderMaterial.new()
	mat.shader = METEOR_SHADER
	mat.set_shader_parameter("base_color", type_data.color)
	mat.set_shader_parameter("seed", our_seed)
	
	for param in type_data.shader:
		mat.set_shader_parameter(param, type_data.shader[param])

	if cracked:
		mat.set_shader_parameter("crack_intensity", 1.0)
	polygon.material = mat
	
	var shape = Global.get_shape(points)
	col.shape = shape
	
	screen_notifier.rect = shape.get_rect()

	traj = Global.world.trajectory_manager.register(shape, true, false)
	update_traj()
	gravity_component.external_impulse_applied.connect(update_traj)
	
	health_component.set_health(type_data.health * (size if type_data.type == Consts.MeteorType.IRON else 1.0))
	hurtbox_component.ignore_dmg_col_layer = Global.get_layer("meteor")
	hurtbox_component.mass = randf_range(type_data.mass_range[0], type_data.mass_range[1])
	hurtbox_component.damage = type_data.damage * size
	
	screen_notifier.screen_entered.connect(update_traj_visibility)
	screen_notifier.screen_exited.connect(update_traj_visibility)
	
	hurtbox_component.hurt.connect(hit)

func hit(_dmg, _source):
	polygon.material.set_shader_parameter("crack_intensity", 1.0)

func die(source: Node2D):
	if source is Bullet:
		if type_data.type == Consts.MeteorType.CHONDRITE and size > 1.0:
			split(source)
		elif type_data.type != Consts.MeteorType.COMET:
			Global.world.meteor_manager.spawn_debris(global_position, type_data, polygon)
	
	Global.world.sound_manager.play("explosion")
	traj.queue_free()
	queue_free()

func split(bullet: Bullet):
	var cut_normal = bullet.get_col_velocity().normalized()
	var cut_spot = to_local(bullet.global_position)
	var chunks = Global.split_polygon(polygon.polygon, cut_normal.rotated(PI / 2), cut_spot)

	for i in 2:
		var kick_dir = cut_normal.rotated(PI / 2) * (1 if i == 0 else -1)
		var new_vel = velocity + kick_dir * 10
		Global.world.meteor_manager.spawn_meteor(global_position, new_vel, type_data.type, 1.0, chunks[i], our_seed, true)

func update_traj():
	traj.update(global_position, velocity)

func update_traj_visibility():
	if screen_notifier.is_on_screen():
		traj.visible = false
	else:
		traj.visible = true
