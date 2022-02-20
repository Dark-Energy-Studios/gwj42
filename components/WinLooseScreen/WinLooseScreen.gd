extends CenterContainer

signal popup_with_message(msg)

func _ready():
	if globals.sound_muted:
		$Panel/Rows/Buttons/Sound.text = "Sound: off"
	else:
		$Panel/Rows/Buttons/Sound.text = "Sound: on"
	connect("popup_with_message", self, "_popup")

func _on_Retry_pressed():
	$ButtonClickSound.play()
	get_parent().emit_signal("new_game")
	hide()

func _on_Menu_pressed():
	$ButtonClickSound.play()
	get_tree().change_scene("res://scenes/Menu.tscn")

func _popup(msg):
	$Panel/Rows/BG/Title.text = msg
	show()

func _on_button_hover():
	var music = AudioStreamPlayer.new()
	music.set_stream(globals.button_hover_sound)
	music.mix_target = AudioServer.get_bus_index("Buttons")
	music.volume_db = -20
	music.pitch_scale = 1
	add_child(music)
	music.play()

func _on_Sound_pressed():
	$ButtonClickSound.play()
	globals.sound_muted = !globals.sound_muted
	
	AudioServer.set_bus_mute(0, globals.sound_muted)
	if globals.sound_muted:
		$Panel/Rows/Buttons/Sound.text = "Sound: off"
	else:
		$Panel/Rows/Buttons/Sound.text = "Sound: on"

