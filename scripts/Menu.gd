extends Control

var hover_sound = preload("res://assets/audio/sound/menu_click_1.mp3")

func _ready():
	hover_sound.loop = false

func _on_CreditFadeOut_timeout():
	$Credits.hide()

func _on_Credits_pressed():
	$ButtonClickSound.play()
	$Credits.show()
	$CreditFadeOut.start(5)

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
	music.set_stream(hover_sound)
	music.mix_target = AudioServer.get_bus_index("Buttons")
	music.volume_db = -20
	music.pitch_scale = 1
	add_child(music)
	music.play()
