@tool
class_name UpgradeType extends HBoxContainer

const UPGRADE_VALUE = preload("uid://cstrp03e80wj8")

var upg_name = "magazine_capacity"
var upg_data

func _ready() -> void:
	upg_data = Consts.UPGRADES[upg_name]
	
	%Title.text = upg_data.title
	%Description.text = upg_data.description
	
	update()
	
	if not Engine.is_editor_hint() and State:
		State.upgrade_purchased.connect(_on_upgrade_purchased)
		State.money_changed.connect(_on_money_changed)
		
		%UpgradeBtn.pressed.connect(_on_upgrade_pressed)

func _on_money_changed(_old: int, new_money: int):
	upd_btn()

func _on_upgrade_purchased(upgrade_type: String):
	update()

func update():
	var cur_idx = 0
	
	if not Engine.is_editor_hint() and State:
		cur_idx = State.get_upgrade_idx(upg_name)
		
	upd_btn()

	for child in %UpgradeValues.get_children():
		child.queue_free()
		
	for i in range(upg_data.values.size()):
		var val_elem = UPGRADE_VALUE.instantiate()
		var val = upg_data.values[i]
		val_elem.text = str(val) + upg_data.unit
		val_elem.checked = i <= cur_idx
		
		%UpgradeValues.add_child(val_elem)

func upd_btn():
	if not Engine.is_editor_hint() and State:
		var cur_idx = State.get_upgrade_idx(upg_name)
		%UpgradeBtn.disabled = !State.can_afford(upg_name)
		%UpgradeBtn.text = Consts.format_money(upg_data.costs[cur_idx]) if cur_idx < upg_data.costs.size() else "MAX"

func _on_upgrade_pressed():
	if State.purchase(upg_name):
		update()
