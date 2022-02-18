extends Spatial

var dice_sounds = [
	preload("res://assets/audio/sound/dice_roll_1.mp3"),
	preload("res://assets/audio/sound/dice_roll_2.mp3"),
	preload("res://assets/audio/sound/dice_roll_3.mp3")
]

export (globals.Team) var current_team = globals.Team.PLAYER

var currently_rolling: bool = false
var player_score: int = 0
var enemy_score: int = 0

func _ready():
	$UI/Centered/Panel/TurnLabel.text = "Turn of %s" % globals.team_to_string(current_team)
	
	# let all dice call our _on_dice_rolled function if roll has been finished
	for die in $Dice.get_children():
		(die as Die).connect("rolled", self, "_on_dice_rolled")
	
	# let all player chips call _on_player_chip_clicked on clicking
	for chip in $PlayerChips.get_children():
		chip.connect("clicked", self, "_on_chip_clicked")
	
	for chip in $EnemyChips.get_children():
		chip.connect("clicked", self, "_on_chip_clicked")

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

func _on_chip_clicked(chip):
	var target_index = chip.position
	for die in $Dice.get_children():
		if !die.is_sleeping(): return
		target_index += die.number

	# check if chip has finished
	if target_index == $PlayerChips.get_child_count():
		# remove stone
		chip.queue_free()

		# update score
		if current_team == globals.Team.PLAYER:
			player_score += 1
			$"UI/Centered/Panel/Stones-Player".emit_signal("stones_changed", player_score)
		else:
			enemy_score += 1
			$"UI/Centered/Panel/Stones-Opponent".emit_signal("stones_changed", enemy_score)
		return
	
	
	# move chip
	var turn_fields = get_fields()
	chip.move(turn_fields["own"][target_index].position)
	
	# check if chip kicks out opponent chip
	var turn_chips = get_chips()
	for opponent_chip in turn_chips["opponent"]:
		if opponent_chip.position == target_index:
			opponent_chip.reset()
	
	# TODO: check if re-roll
	if turn_fields["own"][target_index].special:
		# re-roll
		pass
	else:
		# pass turn to opponent
		pass
	
func _on_dice_rolled():
	var number = 0
	for die in $Dice.get_children():
		if !die.is_sleeping(): return
		number += die.number

	# early return on number = 0
	
	# check movability of each chip with the rolled dice number
	# if chip is not movable, it won't be clickable
	var turn_chips = get_chips()
	for chip in turn_chips["own"]:
		chip.clickable = is_valid_move(chip, number)

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

func get_chips() -> Dictionary:
	if current_team == globals.Team.PLAYER:
		return { "own": $PlayerChips.get_children(), "opponent":$EnemyChips.get_children()}
	return { "own": $EnemyChips.get_children(), "opponent":$PlayerChips.get_children()}

func get_fields() -> Dictionary:
	if current_team == globals.Team.PLAYER:
		return { "own": $PlayerFields.get_children(), "opponent":$EnemyFields.get_children()}
	return { "own": $EnemyFields.get_children(), "opponent":$PlayerFields.get_children()}

func is_valid_move(chip, number: int) -> bool:
	# if rolled number is zero, there is no valid move at all
	if number == 0: return false
	
	var turn_chips = get_chips()
	
	# calculate the index of the target field
	# use the dice number itself, if chip isn't on the board, yet
	var target_index
	if chip.position == -1:
		target_index = number-1
	else:
		target_index = chip.position + number
	
	# check if another own chip is blocking our movement
	for other_chip in turn_chips["own"]:
		# skip current chip we check moves for
		if chip.get_instance_id() == other_chip.get_instance_id():
			continue
		
		if other_chip.position == target_index:
			# other chip is blocking our current one
			return false
	
	# check out-of-bounds, where chip can only finish the board on landing to the end index + 1
	if target_index == $PlayerFields.get_child_count():
		# chip can directly finish the board
		return true
	elif target_index > $PlayerFields.get_child_count():
		# chip would 'overshot' goal
		return false
			
	# check if opponent chip is at the target index -> valid except field is special
	for opponent_chip in turn_chips["opponent"]:
		if opponent_chip.position == target_index:
			return !$PlayerFields.get_children()[target_index].special

	return true
