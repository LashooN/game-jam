class_name MeteorManager extends Node

const METEOR = preload("uid://lpe27efet5v8")
const DEBRIS = preload("uid://8c6dek316pe1")

signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)

var _active_meteors := 0
var _spawning := false

var cooldown: Timer

func reset():
	cooldown = Timer.new()
	cooldown.one_shot = true
	add_child(cooldown)
	_active_meteors = 0
	_spawning = false

func stop():
	cooldown.stop()

# Wave composition at a given wave number
func get_wave_data(wave: int) -> Dictionary:
	return {
		# How many meteors total — grows slowly
		"count": 6 + int(wave * 1.5),
		
		# Spawn interval — gets faster, bottoms out at 1.5s
		"spawn_interval": max(1.5, 10.0 - wave * 0.4),
		
		# Speed range — gets faster over time
		"speed_min": 20.0 + wave * 1.2,
		"speed_max": 30.0 + wave * 1.8,
		
		# Type weights — more iron and comets as waves progress
		"chondrite_weight": max(0.4, 0.85 - wave * 0.03),
		"iron_weight": min(0.45, 0.10 + wave * 0.025),
		"comet_weight": min(0.25, 0.05 + wave * 0.01),
		
		# Large meteor chance — increases over time
		"large_chance": min(0.6, 0.1 + wave * 0.04),
		
		# Special waves every 5 waves
		"is_boss_wave": false # wave % 5 == 0 and wave > 0,
	}

func start_wave():
	State.wave += 1
	_spawning = true
	wave_started.emit(State.wave)
	
	var data = get_wave_data(State.wave)
	print("Starting wave ", State.wave, ": ", data)
	
	if data.is_boss_wave:
		await _run_boss_wave(data)
	else:
		await _run_normal_wave(data)
	
	_spawning = false
	if Global.running:
		_check_wave_ended()

func _run_normal_wave(data: Dictionary):
	if State.wave == 1:
		data.large_chance = 0.0
		data.iron_weight = 0.0
		data.comet_weight = 0.0
	elif State.wave == 2 or State.wave == 3:
		data.large_chance = 0.0
		data.comet_weight = 0.0
	
	for i in data.count:
		spawn_rand_meteor(data)
		await sleep(data.spawn_interval)

func sleep(secs):
	cooldown.start(secs)
	await cooldown.timeout

func _run_boss_wave(data: Dictionary):
	# Boss wave: one big cluster, then a break, then another cluster
	var half = data.count / 2
	
	# First cluster — fast spawns
	for i in half:
		spawn_rand_meteor(data)
		await sleep(1)
	
	# Brief break — player scrambles to deal with first cluster
	await sleep(10.0)
	
	# Second cluster — faster and bigger
	for i in data.count - half:
		var boosted = data.duplicate()
		boosted.speed_min *= 1.3
		boosted.speed_max *= 1.3
		boosted.large_chance = min(0.8, data.large_chance + 0.2)
		spawn_rand_meteor(boosted)
		await sleep(0.6)

func spawn_rand_meteor(data: Dictionary):
	var pos = get_spawn_position()
	var speed = randf_range(data.speed_min, data.speed_max)
	var towards = -pos.normalized() * speed
	var offset = towards.orthogonal() * randf_range(-0.3, 0.3)
	var vel = towards + offset
	var type = _random_type(data)
	var size = _random_size(data)
	return spawn_meteor(pos, vel, type, size)

func _random_type(data: Dictionary) -> Consts.MeteorType:
	var total = data.chondrite_weight + data.iron_weight + data.comet_weight
	var roll = randf() * total
	if roll < data.chondrite_weight:
		return Consts.MeteorType.CHONDRITE
	elif roll < data.chondrite_weight + data.iron_weight:
		return Consts.MeteorType.IRON
	else:
		return Consts.MeteorType.COMET

func _random_size(data: Dictionary) -> float:
	return 2.0 if randf() < data.large_chance else 1.0

func spawn_meteor(
	pos: Vector2,
	vel: Vector2,
	type: Consts.MeteorType,
	size: float,
	points = null,
	our_seed = randf(),
	cracked = false
) -> Node2D:
	var meteor = METEOR.instantiate()
	meteor.global_position = pos
	meteor.velocity = vel
	meteor.type_data = Consts.METEOR_DATA[type]
	meteor.size = size
	meteor.points = points
	meteor.our_seed = our_seed
	meteor.cracked = cracked
	
	_active_meteors += 1
	meteor.tree_exited.connect(_on_meteor_died)
	
	add_child(meteor)
	return meteor

func _on_meteor_died() -> void:
	_active_meteors -= 1
	
	_check_wave_ended()

func _check_wave_ended() -> void:
	if not _spawning and _active_meteors <= 0:
		wave_ended.emit(State.wave)

func spawn_debris(pos: Vector2, type_data, polygon):
	var debris = DEBRIS.instantiate()
	debris.global_position = pos
	debris.type_data = type_data
	debris.polygon = polygon
	add_child(debris)

func get_spawn_position() -> Vector2:
	return Global.world.spawn_zone.get_rand_point()
