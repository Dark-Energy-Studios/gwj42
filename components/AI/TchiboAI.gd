extends BaseAI
class_name TchiboAI


func _init():
	name = "Tch1b0"

func get_chips_positions(chips) -> Array:
	var positions := []
	for chip in chips:
		positions.append(chip.position)

	return positions

func make_move(dice_roll: int, ai_chips, player_chips, _fields):
	# if the ai is able to kick a player-chip out, do it
	for ai_chip in ai_chips:
		for player_chip in player_chips:
			if ai_chip.position + dice_roll == player_chip.position:
				_trigger_move(ai_chip)
				return

	# if there are at least 3 ai-chips currently on the filed
	if ai_chips.size() - get_chips_positions(ai_chips).count(-1) >= 3:
		for chip in ai_chips:
			if chip.position != -1:
				_trigger_move(chip)
				return
	else:
		for chip in ai_chips:
			if chip.position == -1:
				_trigger_move(chip)
				return

	_trigger_move(ai_chips[0])
