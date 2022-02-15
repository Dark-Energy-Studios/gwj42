extends Object

class_name BaseAI

var name = "Arth'Ur Dent"

func _init():
	pass
	
func make_move(dice_roll, ai_chips, player_chips):
	var usable_chips = []
	for chip in ai_chips.get_children():
		if chip.clickable: usable_chips.push_back(chip)
	
	_trigger_move(usable_chips[0])

func _trigger_move(chip):
	chip.emit_signal("mouse_entered")
	yield(chip.get_tree().create_timer(0.5), "timeout")
	chip.emit_signal("clicked", chip)
	yield(chip.get_tree().create_timer(0.5), "timeout")
	chip.emit_signal("mouse_exited")
