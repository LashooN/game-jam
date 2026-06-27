class_name WeaponComponent extends Node

#@export var min_weapon_speed := 100.0
#@export var max_weapon_speed := 500.0
#@export var weapon_speed_step := 50.0

@export var weapon_speed := 100.0
@export var cooldown := 0.1

var magazine := 1:
	get:
		return State.get_upgrade_value("magazine_capacity")
		
var ammo := 1

var aim_traj: Trajectory

var enabled = true

var _parent: Node2D

var target_pos: Vector2 = Vector2.ZERO
var base_pos: Vector2 = Vector2.ZERO

var cooldown_timer = Timer.new()
var reload_timer = Timer.new()

var cur_speed_mode_idx = 0

const BULLET = preload("uid://c8gr02yl3ckke")

var bullet_proto: Bullet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_parent = get_parent()
	bullet_proto = BULLET.instantiate()
	var col = bullet_proto.get_node_or_null("CollisionShape2D") as CollisionShape2D
	aim_traj = Global.world.trajectory_manager.register(col.shape, false, true)
	
	cooldown_timer.one_shot = true
	reload_timer.one_shot = true
	add_child(cooldown_timer)
	add_child(reload_timer)
	
	alter_speed_mode(0)
	
	reload_timer.timeout.connect(_on_reload_timeout)
	State.upgrade_purchased.connect(_on_upgrade_purhased)
	ammo = magazine

func _on_upgrade_purhased(upg):
	if upg == "magazine_capacity":
		reload()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if _parent.global_position == base_pos:
		return
		
	base_pos = _parent.global_position
	update_vel()

func set_target(new_target_pos: Vector2):
	if target_pos == new_target_pos:
		return
		
	target_pos = new_target_pos
	update_vel()


func alter_speed_mode(val: float):
	var vals = Consts.UPGRADES["bullet_speed"].values
	cur_speed_mode_idx = clamp(cur_speed_mode_idx + val, 0, State.get_upgrade_idx("bullet_speed"))
	weapon_speed = clamp(float(vals[cur_speed_mode_idx]), 100.0, 500.0)
	update_vel()
	
func update_vel() -> Vector2:
	var vel = (target_pos - base_pos).normalized() * weapon_speed
	aim_traj.update(base_pos, vel)
	return vel

func shoot():
	if not enabled:
		return

	if !cooldown_timer.is_stopped() or !reload_timer.is_stopped():
		return
		
	cooldown_timer.start(cooldown)
		
	var vel = update_vel()
	Global.world.bullet_manager.spawn_bullet(base_pos, vel)
	
	State.money -= Consts.BULLET_COST
	ammo -= 1
	Global.world.sound_manager.play("shoot")
	if ammo <= 0: 
		var reload_time = State.get_upgrade_value("fire_rate") * (1 + float(State.get_upgrade_value("magazine_capacity") - 1) * 0.75) 
		reload_timer.start(reload_time)
	
	# recoil
	_parent.gravity_component.apply_impulse(-vel.normalized() * 3.0)

func _on_reload_timeout():
	Global.world.sound_manager.play("reload")
	reload()

func reload():
	ammo = State.get_upgrade_value("magazine_capacity")
