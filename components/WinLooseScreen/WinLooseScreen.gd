extends CenterContainer

signal popup_with_message(msg)

func _ready():
	connect("popup_with_message", self, "_popup")

func _on_Retry_pressed():
	get_parent().emit_signal("new_game")
	hide()

func _on_Menu_pressed():
	get_tree().change_scene("res://scenes/Menu.tscn")

func _popup(msg):
	$Panel/Rows/BG/Title.text = msg
	show()
