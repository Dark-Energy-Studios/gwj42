extends Spatial

var dice_sounds = [
	preload("res://assets/audio/sound/dice_roll_1.mp3"),
	preload("res://assets/audio/sound/dice_roll_2.mp3"),
	preload("res://assets/audio/sound/dice_roll_3.mp3")
]

const TURN_PLAYER_TEXT = "It's your turn!"
const TURN_OPPONENT_TEXT = "It's Arthurs turn"

func _ready():
	$UI/Centered/Panel/TurnLabel.text = TURN_PLAYER_TEXT

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
	$GameController.roll_dice()

func _on_GameController_switch_turn(turn_owner: int):
	$TokenSound.play()
	if turn_owner == globals.Team.PLAYER:
		$UI/Centered/Panel/TurnLabel.text = TURN_PLAYER_TEXT
	else:
		$UI/Centered/Panel/TurnLabel.text = TURN_OPPONENT_TEXT
		
	$GameController.currently_rolling = false
	print_debug($GameController.currently_rolling)

func play_dice_sound():
	if $DiceSound.playing: return
	
	yield(get_tree().create_timer(.7), "timeout")
	$DiceSound.stream = dice_sounds[randi() % dice_sounds.size()]
	$DiceSound.play()
