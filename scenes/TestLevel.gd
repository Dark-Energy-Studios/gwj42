extends Spatial

var dice_sounds = [
	preload("res://assets/audio/sound/dice_roll_1.mp3"),
	preload("res://assets/audio/sound/dice_roll_2.mp3"),
	preload("res://assets/audio/sound/dice_roll_3.mp3")
]

export (globals.Team) var current_team = globals.Team.PLAYER

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
	print_debug($GameController.currently_rolling)
	
	if $GameController.currently_rolling: return 
		
	play_dice_sound()
    for die in $Dice.get_children():
            (die as Die).roll()

func _on_dice_rolled(number: int):
	print_debug("rolled a " + str(number))

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
