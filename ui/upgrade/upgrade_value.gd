@tool
class_name UpgradeValue extends VBoxContainer

var checked: bool = false:
	set(value):
		checked = value
		upd_rect()
var text: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%UpgradeValue.text = text
	upd_rect()

func upd_rect():
	%ValueRect.color = Color.WHITE if checked else Color.BLACK
