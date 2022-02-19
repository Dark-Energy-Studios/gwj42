extends Control

func _ready():
	pass

func _on_CreditFadeOut_timeout():
	$Credits.hide()

func _on_Credits_pressed():
	$Credits.show()
	$CreditFadeOut.start(5)

func _on_Play_pressed():
	get_tree().change_scene("res://scenes/TestLevel.tscn")

func _on_Rules_pressed():
	$Rules.show()

func _on_GoHomeButton_pressed():
	$Rules.hide()
	$Credits.hide()
	$Menu.show()

func _on_Quit_pressed():
	get_tree().quit(0)
