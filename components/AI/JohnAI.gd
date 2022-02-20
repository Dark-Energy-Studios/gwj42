extends BaseAI
class_name JohnAI

func _init():
	self.name = "j0braun"

func make_move(dice_roll: int, ai_chips, player_chips, fields) -> void:
	for my_chip in ai_chips:
		for other_chip in player_chips:
			var my_pos = my_chip.position
			var other_pos = other_chip.position
			if my_pos < 4 or my_pos > 11: continue
			if my_pos in [other_pos + 1, other_pos + 2, other_pos + 3]:
				_trigger_move(my_chip)
	
	if get_chips_positions(ai_chips).count(-1) > 4:
		for chip in ai_chips:
			if chip.position == -1:
				_trigger_move(chip)
				return

	_trigger_move(ai_chips[0])
