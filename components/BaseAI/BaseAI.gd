extends Object

class_name BaseAI

var name = "Arth'Ur Dent"

func _init():
	pass
	
func make_move(dice_roll, ai_chips, player_chips):
	var usable_chips = []
	for chip in ai_chips.get_children():
		if chip.clickable: usable_chips.push_back(chip)
	
	var chip = usable_chips[0]
	chip.emit_signal("clicked", chip)
