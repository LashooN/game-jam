extends CanvasLayer

func _ready() -> void:
	State.wave_changed.connect(_on_wave_changed)
	State.money_changed.connect(_on_money_changed)
	_on_money_changed(0, State.money)
	_on_wave_changed(State.wave)

func _get_custom_actions() -> String:
	var lines: Array[String] = []
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		var events := InputMap.action_get_events(action)
		var keys := events.map(func(e):
			var text = e.as_text()
			text = text.replace("- Physical", "")
			return text
		)
		lines.append("%s: %s" % [action, ", ".join(keys)])
	return "\n".join(lines)

func _on_money_changed(_old: int, new_money: int):
	%Money.text = Consts.format_money(new_money)

func _on_wave_changed(wave_num: int):
	%Wave.text = str(wave_num)
