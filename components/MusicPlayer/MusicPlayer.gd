extends Node
class_name MusicPlayer

export(Dictionary) var tracks
export(float) var volume_db = 0
export(float, 0.1, 5, 0.1) var transition_time = 1.5
export(bool) var autoplay = false
export(String) var autoplay_key

onready var current_player = $AudioStreamPlayer
onready var passive_player = $AudioStreamPlayer2

func _ready():
	if autoplay:
		play(autoplay_key)

func play(name: String, position: float = 0):
	# if the player is currently not playing
	if !current_player.playing:
		current_player.stream = tracks[name]
		current_player.play(position)
	else:
		# Start the transition between the two audios
		$Tween.interpolate_property(current_player, "volume_db", current_player.volume_db, -80, 1.5)
		$Tween.interpolate_property(passive_player, "volume_db", -10, self.volume_db, 1.5)
		passive_player.stream = tracks[name]
		passive_player.play(position)
		$Tween.start()

func pause():
	current_player.stop()

func is_playing():
	return current_player.playing

func _on_Tween_tween_all_completed():
	# Swap passive and current player
	var tmp = current_player
	current_player = passive_player
	passive_player = tmp
