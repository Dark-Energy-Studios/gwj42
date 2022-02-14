extends Spatial

var dice_sounds = [
	preload("res://assets/audio/sound/dice_roll_1.mp3"),
	preload("res://assets/audio/sound/dice_roll_2.mp3"),
	preload("res://assets/audio/sound/dice_roll_3.mp3")
]

func _ready():
	$TurnLabel.text = "Turn of Player"

func _process(_delta):
	if Input.is_action_just_pressed("r_key"):
		play_dice_sound()
		$GameController.roll_dice()

func _on_GameController_switch_turn(turn_owner: int):
	$TokenSound.play()
	if turn_owner == globals.Team.PLAYER:
		$TurnLabel.text = "Turn of Player"
	else:
		$TurnLabel.text = "Turn of Enemy"

func play_dice_sound():
	if $DiceSound.playing: return
	
	yield(get_tree().create_timer(.7), "timeout")
	$DiceSound.stream = dice_sounds[randi() % dice_sounds.size()]
	$DiceSound.play()
