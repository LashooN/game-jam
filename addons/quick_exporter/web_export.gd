@tool
extends EditorScript

const EXPORT_DIR := "res://export/web"
const ZIP_PATH   := "res://export/build.zip"
const PRESET_NAME := "Web"  # must match exactly in export_presets.cfg

func _run() -> void:
	print("Starting Web export...")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EXPORT_DIR))

	var export_path := ProjectSettings.globalize_path(EXPORT_DIR + "/index.html")
	var zip_path    := ProjectSettings.globalize_path(ZIP_PATH)
	var godot_bin   := OS.get_executable_path()

	# Export via CLI
	var output := []
	var exit_code := OS.execute(godot_bin, [
		"--headless",
		"--export-release", PRESET_NAME,
		export_path
	], output, true)

	for line in output:
		print(line)

	if exit_code != OK:
		push_error("Export failed with exit code: %d" % exit_code)
		return

	_butler_push()
		
func _butler_push() -> void:
	print("Pushing to itch.io...")
	
	var output := []
	# format is user/game:channel
	var exit_code := OS.execute("butler", [
		"push",
		ProjectSettings.globalize_path("res://export/web"),  # push the folder, not the zip
        "zantario/orbital-sniper:html"
	], output, true)
	
	for line in output:
		print(line)
	
	if exit_code != OK:
		push_error("Butler push failed with exit code: %d" % exit_code)
		return
	
	print("Pushed to itch.io!")
