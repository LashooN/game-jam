class_name TrajectoryManager extends Node

const TRAJECTORY = preload("uid://vlonubv1vq83")

var last_tick = 0.0

func _physics_process(delta: float) -> void:
	if Global.world.time - last_tick >= Global.TRAJECTORY_DT:
		last_tick += Global.TRAJECTORY_DT
		for traj in get_children():
			if traj is Trajectory:
				traj.tick()

func register(shape_col: Shape2D, is_tickable := true, is_visible := true) -> Trajectory:
	var trajectory = TRAJECTORY.instantiate()
	trajectory.visible = is_visible
	trajectory.is_tickable = is_tickable
	trajectory.shape_col = shape_col
	
	add_child(trajectory)
	return trajectory
