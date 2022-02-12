extends Spatial

var current_pos = 0
onready var fields = ($Board/Fields as Spatial).get_children()
var looking_at_dices = true	
onready var interesting_object = get_node("Dices/Dice1")
var rolled_numbers = []
var initial_dice_positions = []

func _ready():
	$Music.play()
	for dice in $Dices.get_children():
		initial_dice_positions.append(dice.global_transform.origin)

func _process(delta):
	$Camera.look_at(interesting_object.global_transform.origin, Vector3.UP)

func move(moves: int) -> void:
	if current_pos + moves > len(fields) - 1: return
	current_pos += moves
	$Player.global_transform.origin = fields[current_pos].global_transform.origin
	$Player.set_sleeping(false)

func _on_LookAt_pressed():
	if looking_at_dices:
		$LookAt.text = "Look at Dices"
		interesting_object = get_node("Player")
	else:
		interesting_object = get_node("Dices/Dice1")
		$LookAt.text = "Look at Player"
	looking_at_dices = !looking_at_dices

func _on_dice_rolled(number: int) -> void:
	rolled_numbers.append(number)
	print("Rolled number %d" % number)
	if len(rolled_numbers) == 4:
		var sum = 0
		for num in rolled_numbers: sum += num
		move(sum)
		rolled_numbers = []

func reroll():
	var dices = $Dices.get_children()
	for i in range(0, len(dices)):
		dices[i].global_transform.origin = initial_dice_positions[i]
		dices[i].set_sleeping(false)
