extends Node

signal money_changed(old: int, new: int)
signal wave_changed(wave: int)
signal upgrade_purchased(id: String)
signal speed_changed(new_speed: float)

var satellite: Satellite

var speed := 1.0:
	set(value):
		speed = value
		speed_changed.emit(speed)
		if Global.running:
			Engine.time_scale = speed

var wave := 0:
	set(value):
		wave = value
		wave_changed.emit(wave)

var money := 2000:
	set(value):
		var old = money
		money = value
		money_changed.emit(old, money)

var upgrade_levels := {
	"fire_rate": 0,
	"bullet_speed": 0,
	"engine_speed": 0,
	"prediction_time": 0,
	"magazine_capacity": 0
}

func reset():
	money = 2000
	wave = 0
	speed = 1.0
	upgrade_levels = {
		"fire_rate": 0,
		"bullet_speed": 0,
		"engine_speed": 0,
		"prediction_time": 0,
		"magazine_capacity": 0
	}

func get_upgrade_value(id: String) -> float:
	var level = upgrade_levels[id]
	return Consts.UPGRADES[id].values[level]

func get_upgrade_idx(id: String) -> int:
	return upgrade_levels[id]

func can_afford(id: String) -> bool:
	var level = upgrade_levels[id]
	var data = Consts.UPGRADES[id]
	if level >= data.costs.size():
		return false
	return money >= data.costs[level]

func purchase(id: String) -> bool:
	if not can_afford(id):
		return false
	var level = upgrade_levels[id]
	money -= Consts.UPGRADES[id].costs[level]
	upgrade_levels[id] += 1
	upgrade_purchased.emit(id)
	return true
