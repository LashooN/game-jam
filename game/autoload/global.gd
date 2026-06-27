extends Node

var rng := RandomNumberGenerator.new()

var game
var world: World

const TRAJECTORY_DT = 1.0 / 10.0

var layers_map = {}

var running = false

func _init() -> void:
	for i in range(1, 33):  # Godot has 32 physics layers
		var name = ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % i)
		if name != "":
			layers_map[name] = 1 << (i - 1)  # layer 1 = bit 0 = value 1

func get_layer(layer_names) -> int:
	if typeof(layer_names) == TYPE_STRING:
		layer_names = [layer_names]
		
	var mask = 0
	for name in layer_names:
		if name in layers_map:
			mask |= layers_map[name]
	return mask

func generate_meteor_points(type: Consts.MeteorType, size_mult: float) -> PackedVector2Array:
	var data = Consts.METEOR_DATA[type]
	
	var base_radius = rng.randf_range(data.radius_range[0], data.radius_range[1]) * size_mult

	var rx = base_radius * clamp(rng.randfn(data.rx_mean, data.rx_std), 0.6, 1.8)
	var ry = base_radius * clamp(rng.randfn(data.ry_mean, data.ry_std), 0.6, 1.8)
	var num_points = rng.randi_range(data.num_points_range[0], data.num_points_range[1])
	var tilt = rng.randf_range(0.0, TAU)

	var points := PackedVector2Array()
	for i in num_points:
		var angle = (float(i) / num_points) * TAU
		var r_variance = clamp(rng.randfn(1.0, data.perturbation_std), 0.7, 1.3)
		var p = Vector2(cos(angle) * rx, sin(angle) * ry) * r_variance
		points.append(p.rotated(tilt))

	return points

func get_shape(points: PackedVector2Array) -> Shape2D:
	var shape = ConvexPolygonShape2D.new()
	shape.set_points(points)
	return shape

func split_polygon(points: PackedVector2Array, cut_normal: Vector2, cut_spot = Vector2.ZERO) -> Array:
	var side_a := PackedVector2Array()
	var side_b := PackedVector2Array()

	var n = points.size()
	for i in n:
		var a = points[i]
		var b = points[(i + 1) % n]
		
		var da = (a - cut_spot).dot(cut_normal)
		var db = (b - cut_spot).dot(cut_normal)
		
		# Which side is point a on
		if da >= 0:
			side_a.append(a)
		else:
			side_b.append(a)
		
		# If edge crosses the cut line, add intersection point to both
		if (da >= 0) != (db >= 0):
			var t = da / (da - db)
			var intersection = a.lerp(b, t)
			side_a.append(intersection)
			side_b.append(intersection)
	
	return [side_a, side_b]
	
