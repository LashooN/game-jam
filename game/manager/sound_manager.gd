class_name SoundManager extends Node

@onready var boost: AudioStreamPlayer = $Boost
@onready var shoot: AudioStreamPlayer = $Shoot
@onready var explosion: AudioStreamPlayer = $Explosion
@onready var money: AudioStreamPlayer = $Money
@onready var reload: AudioStreamPlayer = $Reload

var sounds = {}


func _ready():
	sounds = {
		"boost": boost,
		"shoot": shoot,
		"explosion": explosion,
		"money": money,
		"reload": reload
	}

func is_playing(sound_name: String) -> bool:
	if sounds.has(sound_name):
		return sounds[sound_name].playing
	return false

func play(sound_name: String) -> void:
	if sounds.has(sound_name):
		sounds[sound_name].play()
	
func stop(sound_name: String) -> void:
	if sounds.has(sound_name):
		sounds[sound_name].stop()
