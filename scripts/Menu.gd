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
