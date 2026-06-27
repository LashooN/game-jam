@tool
class_name Zone extends Node2D

@export var show_preview: bool = true:
	set(v): show_preview = v; queue_redraw()
@export var inner := 100.0:
	set(v): inner = v; queue_redraw()
@export var outer := 200.0:
	set(v): outer = v; queue_redraw()
@export var preview_color := Color(1, 0, 0, 0.25):
	set(v): preview_color = v; queue_redraw()

signal entered(node: Node2D)
signal exited(node: Node2D)

var rects = []

func _ready():
	if Engine.is_editor_hint():
		return
		
	_calc_rects()
	
	for r in rects:
		var area := Area2D.new()
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = r.size
		shape.shape = rect
		area.position = r.position + r.size / 2
		area.add_child(shape)
		
		area.collision_layer = Global.get_layer("kill_zone")
		area.collision_mask = Global.get_layer(["player", "bullet", "meteor"])
		area.area_entered.connect(entered.emit)
		area.body_entered.connect(entered.emit)
		area.body_exited.connect(exited.emit)
		area.area_exited.connect(exited.emit)
		
		add_child(area)

func _calc_rects() -> void:
	var s: Vector2
	if Engine.is_editor_hint():
		s = Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	else:
		#s = get_viewport().get_visible_rect().size
		s = Vector2(1920, 1080)

	var w := s.x / 2
	var h := s.y / 2
	var band := outer - inner  # thickness of this ring

	rects = [
		# Top
		Rect2(Vector2(-w - outer, -h - outer), Vector2(s.x + outer * 2, band)),
		# Bottom
		Rect2(Vector2(-w - outer,  h + inner), Vector2(s.x + outer * 2, band)),
		# Left  (only the vertical portion between top/bottom bands)
		Rect2(Vector2(-w - outer, -h - inner), Vector2(band, s.y + inner * 2)),
		# Right
		Rect2(Vector2( w + inner, -h - inner), Vector2(band, s.y + inner * 2)),
	]

func get_rand_point():
	var r = rects[randi() % rects.size()]
	return Vector2(
		r.position.x + randf() * r.size.x,
		r.position.y + randf() * r.size.y
	)

func _draw() -> void:
	if not show_preview or not Engine.is_editor_hint():
		return
	_preview_zone()

func _preview_zone() -> void:
	_calc_rects()
	for r in rects:
		draw_rect(r, preview_color)
