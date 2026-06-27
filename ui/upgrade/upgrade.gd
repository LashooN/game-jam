@tool
extends CanvasLayer

const UPGRADE_TYPE = preload("uid://b0e81tycfqw4u")

signal next_wave

func _ready() -> void:
	for child in %Upgrades.get_children():
		child.queue_free()
		
	for upgrade in Consts.UPGRADES:
		var upg = UPGRADE_TYPE.instantiate()
		upg.upg_name = upgrade
		%Upgrades.add_child(upg)
		
	if not Engine.is_editor_hint():
		%NextBtn.pressed.connect(_on_next_wave_pressed)
		
func _on_next_wave_pressed():
	next_wave.emit()

func update():
	for child in %Upgrades.get_children():
		if child.has_method("update"):
			child.update()
	
