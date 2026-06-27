class_name PlayerManager extends Node

const SATELLITE = preload("uid://qyppgyp81um7")

func spawn_satellite():
	var satellite = SATELLITE.instantiate()
	satellite.global_position = Vector2(175, 0)
	add_child(satellite)
	
