extends Spatial

var dice_sounds = [
	preload("res://assets/audio/sound/dice_roll_1.mp3"),
	preload("res://assets/audio/sound/dice_roll_2.mp3"),
	preload("res://assets/audio/sound/dice_roll_3.mp3")
]

export (globals.Team) var current_team = globals.Team.PLAYER

var player_score: int = 0
var enemy_score: int = 0

var opponent_ai = BaseAI.new()

func _ready():
	$UI/Centered/Panel/LabelContainer/TurnLabel.text = "Turn of %s" % globals.team_to_string(current_team)
	
	# let all dice call our _on_dice_rolled function if roll has been finished
	for die in $Dice.get_children():
		(die as Die).connect("rolled", self, "_on_dice_rolled")
	
	# let all player chips call _on_player_chip_clicked on clicking
	for chip in $PlayerChips.get_children():
		chip.connect("clicked", self, "_on_chip_clicked")
	
	for chip in $EnemyChips.get_children():
		chip.connect("clicked", self, "_on_chip_clicked")

func _process(_delta):
	# TODO: drop dice roll by key
	if Input.is_action_just_pressed("r_key"):
		_roll_dice()
	if Input.is_action_just_pressed("ui_accept"):
		$"UI/Centered/Panel/Stones-Opponent".emit_signal("stones_changed", 5)
		$"UI/Centered/Panel/Stones-Player".emit_signal("stones_changed", 3)

# trigger dice roll
func _roll_dice():
	$RollButton.disabled = true
		
	play_dice_sound()
	for die in $Dice.get_children():
			(die as Die).roll()

func _finish_turn(reroll:bool):
	# check if somebody won
	
	# decide who's next
	# normally the opponent's turn is next except if reroll is true,
	# the the current one can roll again.
	#
	# enable roll-button if player has to go next
	# TODO: re-roll AI if enemy is next

	# pass turn to the next team if current one didn't got a re-roll
	if !reroll:
		if current_team == globals.Team.PLAYER:
			current_team = globals.Team.ENEMY
		else:
			current_team = globals.Team.PLAYER
		
	$UI/Centered/Panel/LabelContainer/TurnLabel.text = "Turn of %s" % globals.team_to_string(current_team)
	if player_score == enemy_score:
		$MusicPlayer.play("default")
	elif player_score > enemy_score:
		$MusicPlayer.play("heroic")
	else:
		$MusicPlayer.play("agressive")
	
	if current_team == globals.Team.PLAYER:
		$RollButton.disabled = false
	else:
		_roll_dice()
	


func _on_chip_clicked(chip):
	# freeze all chips while player has choosen one
	if current_team == globals.Team.PLAYER:
		for chip in $PlayerChips.get_children():
			chip.clickable = false
	
	print("clicked on " + str(chip))
	var target_index = 0
	var dice_number = 0
	for die in $Dice.get_children():
		dice_number += die.number

	if chip.position == -1:
		target_index = dice_number-1
		print("move chip from start to %d -1 = %d" % [dice_number, target_index])
	else:
		target_index = chip.position + dice_number
		print("move chip on board to %d + %d = %d" % [chip.position, dice_number, target_index])
		
	

	# check if chip has finished
	if target_index == $PlayerFields.get_child_count():
		# remove stone
		chip.queue_free()

		# update score
		if current_team == globals.Team.PLAYER:
			player_score += 1
			$"UI/Centered/Panel/Stones-Player".emit_signal("stones_changed", player_score)
			$PlayerChipFinished.play()
		else:
			enemy_score += 1
			$"UI/Centered/Panel/Stones-Opponent".emit_signal("stones_changed", enemy_score)
			$EnemyChipFinished.play()
		_finish_turn(false)
		return
	
	# move chip
	var target_field = get_fields()["own"][target_index]
	chip.move(target_index, target_field.global_transform.origin)
	$TokenSound.play()
	
	# check if chip kicks out opponent chip
	# early return on non-overlapping fields
	if !within_range(target_index, 4, 10):
		_finish_turn(target_field.special)
		return
		
	for opponent_chip in get_chips()["opponent"]:
		if within_range(opponent_chip.position, 4,11) && opponent_chip.position == target_index:
			opponent_chip.reset()
	
	_finish_turn(target_field.special)

func within_range(n:int, minimum:int, maximum:int) -> bool:
	return n >= minimum && n <=maximum

func _on_dice_rolled():
	# every dice will trigger this event, but only the last one passes
	# the loop when every die is sleeping
	var number = 0
	for die in $Dice.get_children():
		if !die.is_sleeping(): return
		print(str(die) + " has rolled " + str(die.number))
		number += die.number

	$UI/Centered/Panel/LabelContainer/DiceNumberLabel.text = str(number)

	# finish turn and early return if dice sum is zero
	if number == 0: 
		_finish_turn(false)
		return
	
	# check movability of each chip with the rolled dice number
	var turn_chips = get_chips()
	var valid_own_chips = []
	for chip in turn_chips["own"]:
		if is_valid_move(chip, number):
			valid_own_chips.append(chip)
			chip.clickable = true
		else:
			chip.clickable = false

	# finish turn if there are no valid turns
	if valid_own_chips.size() == 0:
		_finish_turn(false)
		return

	# for ai: just pass all possible chips
	if current_team == globals.Team.ENEMY:
		opponent_ai.make_move(number, valid_own_chips, turn_chips["opponent"], $EnemyFields.get_children())

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
