extends PanelContainer

func _ready() -> void:
	%Btn10.pressed.connect(_on_btn10_pressed)
	%Btn100.pressed.connect(_on_btn100_pressed)
	%Btn200.pressed.connect(_on_btn200_pressed)
	%Btn300.pressed.connect(_on_btn300_pressed)
	
	%Btn10.focus_mode = Control.FOCUS_NONE
	%Btn100.focus_mode = Control.FOCUS_NONE
	%Btn100.focus_mode = Control.FOCUS_NONE
	%Btn200.focus_mode = Control.FOCUS_NONE
	
	State.speed_changed.connect(_on_speed_changed)
	
func _on_btn10_pressed():
	State.speed = 0.1
	
func _on_btn100_pressed():
	State.speed = 1.0
	
func _on_btn200_pressed():
	State.speed = 2.0
	
func _on_btn300_pressed():
	State.speed = 3.0

func _on_speed_changed(new_speed: float):
	%Btn10.set_pressed_no_signal(new_speed == 0.1)
	%Btn100.set_pressed_no_signal(new_speed == 1.0)
	%Btn200.set_pressed_no_signal(new_speed == 2.0)
	%Btn300.set_pressed_no_signal(new_speed == 3.0)

	
