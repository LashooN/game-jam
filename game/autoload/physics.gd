extends Node

func get_semi_major_axis(pos: Vector2, vel: Vector2) -> float:
	var r = pos.length()
	var v_sq = vel.length_squared()
	return 1.0 / (2.0 / r - v_sq / Consts.GM)

func get_orbital_ellipse(pos: Vector2, vel: Vector2) -> Dictionary:
	var r = pos.length()
	var v_sq = vel.length_squared()

	var a = 1.0 / (2.0 / r - v_sq / Consts.GM)

	var e_vec = (pos * (v_sq / Consts.GM - 1.0 / r)) - (vel * (pos.dot(vel) / Consts.GM))
	var e = e_vec.length()  # 0 = circle, <1 = ellipse, 1+ = escaping
	
	# Semi-minor axis
	var b = a * sqrt(max(1.0 - e * e, 0.0))
	
	# Periapsis and apoapsis distances from Earth
	var periapsis = a * (1.0 - e)   # closest point
	var apoapsis  = a * (1.0 + e)   # farthest point
	
	return {
		"a": a,           # semi-major axis
		"b": b,           # semi-minor axis
		"e": e,           # eccentricity
		"e_vec": e_vec,   # points toward periapsis
		"periapsis": periapsis,
		"apoapsis": apoapsis,
	}
	
func get_orbit_trajectory(pos: Vector2, vel: Vector2, pixel_step := 50.0) -> Array:
	var orbit = get_orbital_ellipse(pos, vel)

	if orbit.e < 1.0:
		return get_ellipse_points(orbit, pixel_step)
	else:
		return get_hyperbola_points(orbit, pos, vel, pixel_step)

	
func get_ellipse_points(orbit: Dictionary, pixel_step: float) -> PackedVector2Array:
	var a = orbit.a
	var b = orbit.b
	var e = orbit.e
	var c = a * e
	
	var center = -orbit.e_vec.normalized() * c
	var tilt = orbit.e_vec.angle()
	
	# Approximate ellipse circumference (Ramanujan's formula)
	var h = pow(a - b, 2.0) / pow(a + b, 2.0)
	var circumference = PI * (a + b) * (1.0 + (3.0 * h) / (10.0 + sqrt(4.0 - 3.0 * h)))
	
	# One point every 5 pixels
	var segments = clamp(int(circumference / pixel_step), 32, 1024)
	
	var points := []
	for i in segments + 1:
		var angle = (float(i) / segments) * TAU
		var p = Vector2(cos(angle) * a, sin(angle) * b)
		p = p.rotated(tilt) + center
		points.append(p)
	
	return points
	
func get_hyperbola_points(orbit: Dictionary, pos: Vector2, vel: Vector2, pixel_step: float) -> PackedVector2Array:
	var a = abs(orbit.a)
	var e = orbit.e
	var b = a * sqrt(e * e - 1.0)
	var tilt = (orbit.e_vec * -1.0).angle()
	var c = a * e
	var center = orbit.e_vec.normalized() * c
	
	var t_start = get_t_from_pos(pos, a, b, tilt, center)
	
	var tangent = Vector2(a * sinh(t_start), b * cosh(t_start)).rotated(tilt)
	var t_direction = 1.0 if tangent.dot(vel) > 0.0 else -1.0
	
	var t_end = t_start + t_direction * 5.0

	var arc_length = abs(b * (sinh(t_end) - sinh(t_start)))
	var steps = clamp(int(arc_length / pixel_step), 32, 1024)  #)

	var points := []
	for i in steps + 1:
		var t = lerp(t_start, t_end, float(i) / steps)
		var p = Vector2(a * cosh(t), b * sinh(t))
		p = p.rotated(tilt) + center
		points.append(p)
	
	return PackedVector2Array(points)
	
func solve_eccentric_anomaly(M: float, e: float) -> float:
	var E = M  # initial guess
	for i in 3:
		E = E - (E - e * sin(E) - M) / (1.0 - e * cos(E))
	return E

func get_ellipse_points_timed(orbit: Dictionary, pos: Vector2, vel: Vector2, pixel_step: float) -> Array:
	var a = orbit.a
	var b = orbit.b
	var e = orbit.e
	var center = -orbit.e_vec.normalized() * (a * e)
	var tilt = orbit.e_vec.angle()
	var period = TAU * sqrt(pow(a, 3.0) / Consts.GM)

	# Find E_start from current position
	var local_start = (pos - center).rotated(-tilt)
	var E_start = atan2(local_start.y / b, local_start.x / a)

	# Convert 5 seconds to mean anomaly delta
	var M_start = E_start - e * sin(E_start)
	
	# tangent of ellipse at E_start
	var tangent = Vector2(-sin(E_start) * a, cos(E_start) * b).rotated(tilt)
	var direction = 1.0 if tangent.dot(vel) > 0.0 else -1.0

	var M_end = M_start + direction * (TAU / period) * 5.0
	var E_end = solve_eccentric_anomaly(M_end, e)
	
	var arc_length = abs(a * (E_end - E_start))
	var steps = max(32, int(arc_length / pixel_step))

	var points := []
	for i in steps + 1:
		var E = lerp(E_start, E_end, float(i) / steps)
		var p = Vector2(cos(E) * a, sin(E) * b).rotated(tilt) + center
		var M = E - e * sin(E)
		var elapsed = abs(M - M_start) * (period / TAU)
		points.append({"pos": p, "time": elapsed})

	return points

func solve_hyperbolic_time(target_tau: float, e: float, t_guess: float) -> float:
	var t = t_guess
	for i in 8:
		var f = e * sinh(t) - t - target_tau
		var df = e * cosh(t) - 1.0
		t -= f / df
	return t

func get_hyperbola_points_timed(orbit: Dictionary, pos: Vector2, vel: Vector2, pixel_step: float) -> Array:
	var a = abs(orbit.a)
	var e = orbit.e
	var b = a * sqrt(e * e - 1.0)
	var tilt = (orbit.e_vec * -1.0).angle()
	var center = orbit.e_vec.normalized() * (a * e)
	var time_scale = sqrt(pow(a, 3.0) / Consts.GM)

	var t_start = get_t_from_pos(pos, a, b, tilt, center)
	var tangent = Vector2(a * sinh(t_start), b * cosh(t_start)).rotated(tilt)
	var t_direction = 1.0 if tangent.dot(vel) > 0.0 else -1.0

	var tau_start = e * sinh(t_start) - t_start
	var tau_end = tau_start + t_direction * (5.0 / time_scale)

	# Solve for t_end analytically
	var t_end = solve_hyperbolic_time(tau_end, e, t_start + t_direction * 2.0)

	# Now sample evenly between t_start and t_end
	var arc_length = abs(b * (sinh(t_end) - sinh(t_start)))
	var steps = max(32, int(arc_length / pixel_step))

	var points := []
	for i in steps + 1:
		var t = lerp(t_start, t_end, float(i) / steps)
		var p = Vector2(a * cosh(t), b * sinh(t)).rotated(tilt) + center
		var tau = e * sinh(t) - t
		var elapsed = abs(tau - tau_start) * time_scale
		points.append({"pos": p, "time": elapsed})

	return points

func get_t_from_pos(pos: Vector2, a: float, b: float, tilt: float, center: Vector2) -> float:
	var local = (pos - center).rotated(-tilt)
	var x_norm = max(local.x / a, 1.0)
	var t = log(x_norm + sqrt(x_norm * x_norm - 1.0))  # always positive
	
	# sinh(t) gives the y component — if local.y is negative, t should be negative
	if local.y < 0.0:
		t = -t
	
	return t

	
func get_orbit_trajectory_timed(pos: Vector2, vel: Vector2, pixel_step := 50.0) -> Array:
	var orbit = get_orbital_ellipse(pos, vel)

	if orbit.e < 1.0:
		return get_ellipse_points_timed(orbit, pos, vel, pixel_step)
	else:
		return get_hyperbola_points_timed(orbit, pos, vel, pixel_step)

func sim_step(pos: Vector2, vel: Vector2, delta := Consts.TRAJECTORY_DT, GM := Consts.GM) -> Dictionary:
	var to_earth = -pos
	var dist_sq = max(to_earth.length_squared(), 500.0)
	var acc = to_earth.normalized() * (GM / dist_sq)
	var new_vel = vel + acc * delta
	var new_pos = pos + new_vel * delta
	
	return {"pos": new_pos, "vel": new_vel}

func cosh(x: float) -> float:
	return (exp(x) + exp(-x)) / 2.0  # was 0.5

func sinh(x: float) -> float:
	return (exp(x) - exp(-x)) / 2.0  # was 0.5
