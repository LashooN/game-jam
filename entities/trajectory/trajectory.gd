class_name Trajectory extends Node2D

@onready var labels: Node = $Labels

var points: RingBuffer
var last_vel = Vector2.ZERO

var time_offset = 0.0

var is_tickable = true

var space: PhysicsDirectSpaceState2D
var col_query: PhysicsShapeQueryParameters2D

var shape_col: Shape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	space = get_world_2d().direct_space_state
	
	col_query = PhysicsShapeQueryParameters2D.new()
	col_query.collide_with_areas = true
	col_query.collision_mask = Global.get_layer("environment")
	col_query.shape = shape_col
	
	State.speed_changed.connect(_on_speed_changed)

func _on_speed_changed(new_speed: float):
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = true
	return
	if Engine.time_scale == 1:
		visible = false
	else:
		visible = true
	
func tick():
	if !is_tickable:
		return
		
	if points == null:
		return
		
	var popped = points.pop_front()
	if popped:
		time_offset = popped["time"]
	
	var last_point = points.peek_back()
	if last_point:
		var next_last_point = Physics.sim_step(last_point["pos"], last_vel, Global.TRAJECTORY_DT)
		if not if_hit_earth(next_last_point["pos"]):
			points.append({"pos": next_last_point["pos"], "time": last_point["time"] + Global.TRAJECTORY_DT})
			last_vel = next_last_point["vel"]
			
	queue_redraw()
	
func update(pos: Vector2, vel: Vector2):
	simulate_trajectory(pos, vel, State.get_upgrade_value("prediction_time"))
	queue_redraw()

func _draw():
	if points == null or points.size() < 2:
		return
		
	if State.speed != 0.1:
		return
		
	for i in points.size() - 1:
		var cur_elem = points.get_elem(i)
		var next_elem = points.get_elem(i + 1)
		if cur_elem == null or next_elem == null:
			continue
		draw_line(cur_elem["pos"], next_elem["pos"], time_to_color(cur_elem["time"] - time_offset)[0], 5.0, true)

func if_hit_earth(pos: Vector2) -> bool:
	col_query.transform = Transform2D(0, pos)
	return space.intersect_shape(col_query, 1).size() > 0

func simulate_trajectory(pos: Vector2, vel: Vector2, total = 5.0) -> void:
	var sim_pos = pos
	var sim_vel = vel
	var elapsed := 0.0

	points = RingBuffer.new(round(total / Global.TRAJECTORY_DT))

	while elapsed + Global.TRAJECTORY_DT <= total:
		var step = Physics.sim_step(sim_pos, sim_vel, Global.TRAJECTORY_DT)
		if if_hit_earth(step.pos):
			break
		sim_pos = step.pos
		sim_vel = step.vel
			
		elapsed += Global.TRAJECTORY_DT
		points.append({"pos": sim_pos, "time": elapsed})
	
	points.set_cap_to_size()
	last_vel = sim_vel

func time_to_color(t_norm: float) -> Array:
	#return Color(1.0 - t_norm, t_norm, 0.0) c
	
	var band = int(t_norm)
	match band:
		0: return [Color(1.0, 0.0, 0.0), "red"]
		1: return [Color(1.0, 0.5, 0.0), "orange"]
		2: return [Color(1.0, 1.0, 0.0), "yellow"]
		3: return [Color(0.0, 1.0, 0.0), "green"]
		4: return [Color(0.0, 1.0, 1.0), "cyan"]
		5: return [Color(0.0, 0.0, 1.0), "blue"]
		6: return [Color(0.5, 0.0, 1.0), "purple"]
		_ : return [Color(1.0, 1.0, 1.0), "white"]

	#var band = int(t_norm * 6.0)
	#match band:
		#0: return Color(1.0, 0.0, 0.0) 
		#1: return Color(1.0, 0.5, 0.0) 
		#2: return Color(1.0, 1.0, 0.0) 
		#3: return Color(0.0, 1.0, 0.0)
		#4: return Color(0.0, 1.0, 1.0)
		#5: return Color(0.0, 0.0, 1.0) 
		#6: return Color(0.5, 0.0, 1.0) 
		#_ : return Color(1.0, 1.0, 1.0)
