extends Control


func _ready():
	if globals.sound_muted:
		$Menu/List/Sound.text = "Sound: off"
	else:
		$Menu/List/Sound.text = "Sound: on"

func _on_CreditFadeOut_timeout():
	$Credits.hide()

func _on_Credits_pressed():
	$ButtonClickSound.play()
	$Credits.show()
	$CreditFadeOut.start(5)
	$Menu/List/Credits.release_focus()

func _on_Play_pressed():
	# play button sound and sleep for a bit to hear the full magnificence of the sound
	$ButtonClickSound.play()
	yield(get_tree().create_timer(.3), "timeout")
	
	get_tree().change_scene("res://scenes/TestLevel.tscn")

func _on_Rules_pressed():
	$ButtonClickSound.play()
	$Rules.show()

func _on_GoHomeButton_pressed():
	$ButtonClickSound.play()
	$Rules.hide()
	$Credits.hide()
	$Menu.show()

func _on_Quit_pressed():
	# play button sound and sleep for a bit to hear the full magnificence of the sound	
	$ButtonClickSound.play()
	yield(get_tree().create_timer(.3), "timeout")
	
	get_tree().quit(0)

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
		$Menu/List/Sound.text = "Sound: off"
	else:
		$Menu/List/Sound.text = "Sound: on"
