extends PanelContainer


func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0.25))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Muffled"), linear_to_db(0.25))
	
	%Slider.value_changed.connect(_on_h_slider_value_changed)
	%Slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

func _on_h_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)

	if value <= 0.001:
		db = -80.0

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		db
	)
	
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Muffled"),
		db
	)
