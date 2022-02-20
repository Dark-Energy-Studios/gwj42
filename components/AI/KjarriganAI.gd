extends BaseAI
class_name KjarriganAI

func _init():
	self.name = "Kjarrigan"

func make_move(dice_roll, ai_chips, player_chips, fields):
	# first priority: move chips into the safety zone
	for chip in ai_chips:
		if chip.position + dice_roll >= 12:
			_trigger_move(chip)
			return

	# second priority: move new chips in
	for chip in ai_chips:
		if chip.position == -1:
			_trigger_move(chip)
			return
	
	_trigger_move(ai_chips[0])
