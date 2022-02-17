extends Spatial

var dice_sounds = [
	preload("res://assets/audio/sound/dice_roll_1.mp3"),
	preload("res://assets/audio/sound/dice_roll_2.mp3"),
	preload("res://assets/audio/sound/dice_roll_3.mp3")
]

export (globals.Team) var current_team = globals.Team.PLAYER

var currently_rolling: bool = false

func _ready():
	$UI/Centered/Panel/TurnLabel.text = "Turn of %s" % globals.team_to_string(current_team)
	for die in $Dice.get_children():
		(die as Die).connect("rolled", self, "_on_dice_rolled")

func _process(_delta):
	if Input.is_action_just_pressed("r_key"):
		_roll_dice()
	if Input.is_action_just_pressed("ui_accept"):
		$"UI/Centered/Panel/Stones-Opponent".emit_signal("stones_changed", 5)
		$"UI/Centered/Panel/Stones-Player".emit_signal("stones_changed", 3)

func _roll_dice():
	print_debug(currently_rolling)
	
	if currently_rolling: return 
	currently_rolling = true
		
	play_dice_sound()
	for die in $Dice.get_children():
			(die as Die).roll()

func _on_dice_rolled(number: int):
	print_debug("rolled a " + str(number))
	
	# early return on number = 0
	
	# check movability of each chip with the rolled dice number
	# if chip is not movable, it won't be clickable
	var ownChips
	var opponentChips
	[ownChips, opponentChips] = get_chips()
	for chip in ownChips:
		(chip as Chip).clickable = is_valid_move(chip, number)

func _on_GameController_switch_turn(turn_owner: int):
	$TokenSound.play()
	$TurnLabel.text = "Turn of %s" % globals.team_to_string(current_team)
		
	$GameController.currently_rolling = false
	print_debug($GameController.currently_rolling)

func play_dice_sound():
	if $DiceSound.playing: return
	
	yield(get_tree().create_timer(.7), "timeout")
	$DiceSound.stream = dice_sounds[randi() % dice_sounds.size()]
	$DiceSound.play()

func get_chips() -> Array:
	if current_team == globals.Team.PLAYER:
		return [$PlayerChips,$EnemyChips]
	return [$EnemyChips, $PlayerChips]

func is_valid_move(chip: Chip, number: int) -> bool:
	var own_chips:Array
	var opponent_chips:Array
	[own_chips, opponent_chips] = get_chips()
	
	# calculate the index of the target field
	# use the dice number itself, if chip isn't on the board, yet
	var target_index
	if chip.position == -1:
		target_index = number
	else:
		target_index = chip.position + number
	
	# check if another own chip is blocking our movement
	for other_chip in own_chips:
		# skip current chip we check moves for
		if chip.get_instance_id() == other_chip.get_instance_id():
			continue
		
		if other_chip.position == target_index:
			# other chip is blocking our current one
			return false
	
	# check out-of-bounds, where chip can only finish the board on landing to the end index + 1
	if target_index == $PlayerFields.size():
		# chip can directly finish the board
		return true
	elif target_index > $PlayerFields.size():
		# chip would 'overshot' goal
		return false
			
	# check if opponent chip is at the target index -> valid except field is special
	for opponent_chip in opponent_chips:
		if opponent_chip.position == target_index:
			return !$PlayerFields[target_index].special

	return true
