extends CanvasLayer


func _ready():
	%RestartBtn.pressed.connect(_on_restart_pressed)

func _on_restart_pressed():
	Global.world.transition_manager.restart()
