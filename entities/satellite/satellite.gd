class_name Satellite extends Area2D

var orbit_line: Line2D

var orbit_dirty = true

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var collection_area: Area2D = $CollectionArea

@onready var weapon_component: WeaponComponent = %WeaponComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var gravity_component: GravityComponent = %GravityComponent
@onready var ship: Node2D = $Ship
@onready var fire: Node2D = $Ship/Fire

func _ready():
	State.satellite = self
	orbit_line = add_line(Color(0.5, 0.5, 1.0, 0.5), 3.0)

	%GravityComponent.apply_stable_orbit()
	draw_orbit_preview()
	
	collection_area.area_entered.connect(_on_area_entered)

func add_line(color: Color, width = 3.0) -> Line2D:
	var line = Line2D.new()
	line.width = width
	line.default_color = color
	line.z_index = -1
	get_parent().add_child.call_deferred(line) 
	return line

func _process(delta):
	ship.rotation = gravity_component.velocity.angle() - PI / 2
	collision_shape_2d.rotation = gravity_component.velocity.angle() - PI / 2
	
	if orbit_dirty:
		draw_orbit_preview()

func _physics_process(delta):
	var is_prograde = Input.is_action_pressed("forward")
	var is_retrograde = Input.is_action_pressed("backward")

	if is_prograde or is_retrograde:
		gravity_component.apply_impulse(gravity_component.velocity.normalized() * State.get_upgrade_value("engine_speed") * delta * (-1 if is_retrograde else 1))
		orbit_dirty = true
		
		fire.visible = true
		fire.rotation = 0 if is_prograde else PI
		if not Global.world.sound_manager.is_playing("boost"):
			Global.world.sound_manager.play("boost")
	else:
		fire.visible = false
		Global.world.sound_manager.stop("boost")
		
func draw_orbit_preview():
	orbit_line.points = Physics.get_orbit_trajectory(global_position, gravity_component.velocity)

func _input(event):
	if event is InputEventMouseMotion:
		%WeaponComponent.set_target(get_global_mouse_position())

func _unhandled_input(event):
	if not Global.running:
		return
	
	if event.is_action_pressed("increase"):
		%WeaponComponent.alter_speed_mode(1)
	elif event.is_action_pressed("decrease"):
		%WeaponComponent.alter_speed_mode(-1)
		
	if event.is_action_pressed("shoot"):
		%WeaponComponent.shoot()
		
	if event.is_action_pressed("speed_1"):
		State.speed = 1
	elif event.is_action_pressed("speed_2"):
		State.speed = 2
	elif event.is_action_pressed("speed_3"):
		State.speed = 3
	elif event.is_action_pressed("pause"):
		if State.speed == 0.1:
			State.speed = 1
		else:
			State.speed = 0.1
		
func _on_area_entered(area):
	if area is Debris:
		Global.world.sound_manager.play("money")
		State.money += randi_range(area.type_data.debris_value_range[0], area.type_data.debris_value_range[1])
		area.queue_free()

func die(source):
	Global.world.transition_manager.game_over()
	queue_free()
