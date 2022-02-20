extends BaseAI
class_name EvilcookieAI

func _init():
	self.name = "3vilc00kie"

func make_move(dice_roll: int, ai_chips, player_chips, fields) -> void:
	# first priority: move to special field or enter the finish
	for chip in ai_chips:
		var next_pos = chip.position + dice_roll
		if next_pos == 14 or fields[next_pos].special:
			_trigger_move(chip)
			return

	# second priority: kick players out in the first half of the board
	for my_chip in ai_chips:
		var my_next_pos = my_chip.position + dice_roll
		if my_next_pos > 7: continue
		for other_chip in player_chips:
			if my_next_pos == other_chip.position:
				_trigger_move(my_chip)
				return

	# third priority: move chip on the middle-special field last
	for chip in ai_chips:
		if chip.position != 7:
			_trigger_move(chip)
			return

	_trigger_move(ai_chips[0])
