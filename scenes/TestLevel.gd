extends Spatial

var initial_dice_pos: Array

func _ready():
	$TurnLabel.text = "Turn of Player"
	for dice in $Dices.get_children():
		initial_dice_pos.append(dice.global_transform.origin)

func _process(_delta):
	if Input.is_action_just_pressed("r_key"):
		var dices = $Dices.get_children()
		for i in range(0, len(dices)):
			dices[i].global_transform.origin = initial_dice_pos[i]
			dices[i].set_sleeping(false)


func _on_GameController_switch_turn(turn_owner: int):
	if turn_owner == globals.Team.PLAYER:
		$TurnLabel.text = "Turn of Player"
	else:
		$TurnLabel.text = "Turn of Enemy"
