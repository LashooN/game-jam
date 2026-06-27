# plugin.gd
@tool
extends EditorPlugin

func _enter_tree() -> void:
	print("sw")
	add_tool_menu_item("Export Web + Zip", _run_export)

func _exit_tree() -> void:
	remove_tool_menu_item("Export Web + Zip")

func _run_export() -> void:
	var script = load("res://addons/quick_exporter/web_export.gd").new()
	script._run()
