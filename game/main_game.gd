extends Node

const WORLD = preload("uid://ds0h4nvuf56ay")

@onready var hud: CanvasLayer = $Hud
@onready var menu: CanvasLayer = $Menu
@onready var world_parent: Node2D = $WorldParent
@onready var upgrade: CanvasLayer = $Upgrade
@onready var game_over: CanvasLayer = $GameOver
@onready var tutorial: CanvasLayer = $Tutorial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game = self
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play():
	var world = WORLD.instantiate()
	while world_parent.get_child_count() > 0:
		world_parent.get_child(0).queue_free()
	world_parent.add_child(world)
	menu.visible = false
