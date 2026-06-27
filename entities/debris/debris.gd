class_name Debris extends Area2D

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var type_data := Consts.METEOR_DATA[Consts.MeteorType.CHONDRITE]
var polygon: Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	polygon_2d.material = polygon.material
	polygon_2d.material.set_shader_parameter("debris", true)
	
	var scaled_poly = scale_polygon(polygon.polygon, 2)
	
	polygon_2d.polygon = scaled_poly
	collision_shape_2d.shape = Global.get_shape(scaled_poly)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func scale_polygon(points: PackedVector2Array, factor: float) -> PackedVector2Array:
	var center := Vector2.ZERO

	for p in points:
		center += p
	center /= points.size()

	var result := PackedVector2Array()

	for p in points:
		result.append(center + (p - center) * factor)

	return result
