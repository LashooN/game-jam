#extends ProgressBar
#
#
#func _process(delta) -> void:
	#if State.satellite:
		#var cooldown = State.get_upgrade_value("fire_rate")
		#max_value = cooldown
		#value = cooldown - State.satellite.weapon_component.cooldown_timer.time_left

extends ProgressBar

@export var weapon: WeaponComponent

func _draw():
	var w = size.x
	var h = size.y
	var segment_width = w / weapon.magazine
	for i in range(1, weapon.magazine):
		var x = segment_width * i
		draw_line(Vector2(x, 0), Vector2(x, h), Color(0, 0, 0, 0.8), 2.0)
		
func _process(delta):
	if not weapon.reload_timer.is_stopped():
		get("theme_override_styles/fill").bg_color = Color("d2663cff")
		value = (weapon.reload_timer.wait_time - weapon.reload_timer.time_left) / weapon.reload_timer.wait_time
		return
		
	var ammo_perc = float(weapon.ammo) / float(weapon.magazine)
		
	if not weapon.cooldown_timer.is_stopped():
		get("theme_override_styles/fill").bg_color = Color("d2663cff")
		var perc = weapon.cooldown_timer.time_left / weapon.cooldown_timer.wait_time
		
		value = ammo_perc + perc / float(weapon.magazine)
		return
		
	get("theme_override_styles/fill").bg_color = Color("#6fad41")
		
	value = ammo_perc
	
