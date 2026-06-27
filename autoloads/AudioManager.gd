extends Node

var _sfx_pool: Array = []
var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)

	for i in 8:
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % i
		add_child(player)
		_sfx_pool.append(player)




	pass

func play_sfx(filename: String, pitch_scale: float = 1.0) -> void:
	pass # Full implementation Epic 07

func play_music(filename: String) -> void:
	pass # Full implementation Epic 07
