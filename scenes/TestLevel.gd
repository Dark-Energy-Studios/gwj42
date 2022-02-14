extends Spatial

func _ready():
	$TurnLabel.text = "Turn of Player"

func _process(_delta):
	if Input.is_action_just_pressed("r_key"):
		$GameController.roll_dice()
		
func _on_GameController_switch_turn(turn_owner: int):
	if turn_owner == globals.Team.PLAYER:
		$TurnLabel.text = "Turn of Player"
	else:
		$TurnLabel.text = "Turn of Enemy"
