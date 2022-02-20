extends Control
class_name Profile

signal challenged(profile)

export(String) var persons_name
export(String, MULTILINE) var description
export(Texture) var image

func _ready():
	$VBoxContainer/name.text = persons_name
	$VBoxContainer/description.text = description
	$VBoxContainer/TextureRect.texture = image


func _on_Button_pressed():
	emit_signal("challenged", self)
