class_name TransitionManager extends Node

@export var meteors: MeteorManager

func start():
	if not Global.game.tutorial.finished:
		Global.game.tutorial.start()
	else:
		wave_loop()

func wave_loop():
	Global.world.resume()
	
	meteors.start_wave()
	await meteors.wave_ended
	await get_tree().create_timer(3.0).timeout
	
	if not Global.running:
		return
		
	Global.world.pause()
	
	Global.game.upgrade.update()
	Global.game.upgrade.visible = true
	await Global.game.upgrade.next_wave
	Global.game.upgrade.visible = false
	wave_loop()
	
func game_over():
	Global.world.pause()
	Global.game.upgrade.visible = false
	Global.game.game_over.visible = true
	
func restart():
	Global.game.game_over.visible = false
	Global.world.reset()
