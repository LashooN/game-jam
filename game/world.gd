class_name World extends Node2D

@onready var bullet_manager: BulletManager = $BulletManager
@onready var player_manager: PlayerManager = $PlayerManager
@onready var trajectory_manager: TrajectoryManager = $TrajectoryManager
@onready var meteor_manager: MeteorManager = $MeteorManager
@onready var transition_manager: TransitionManager = $TransitionManager
@onready var sound_manager: SoundManager = $SoundManager

@onready var kill_zone: Zone = $Level/KillZone
@onready var spawn_zone: Zone = $Level/SpawnZone

var time: float = 0.0

var time_scale = 1.0

func _ready() -> void:
	Global.world = self
	
	kill_zone.entered.connect(_on_kill_zone_entered)
	
	reset()

func reset():
	for child in bullet_manager.get_children():
		child.queue_free()
		
	for child in meteor_manager.get_children():
		child.queue_free()
		
	for child in player_manager.get_children():
		child.queue_free()
		
	for child in trajectory_manager.get_children():
		child.queue_free()
		
	Global.running = true
	
	State.reset()
	%Earth.reset()
	meteor_manager.reset()
	
	player_manager.spawn_satellite()
	
	transition_manager.start()
	
	Engine.time_scale = 1

func _physics_process(delta: float) -> void:
	time += delta

func _on_kill_zone_entered(node: Node2D):
	if node.has_method("die"):
		node.die(null)
	else:
		node.queue_free()

func pause():
	Engine.time_scale = 0
	Global.running = false

func resume():
	Engine.time_scale = 1
	Global.running = true
