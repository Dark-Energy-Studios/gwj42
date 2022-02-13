extends Node
class_name GameController

signal switch_turn(turn_owner)

export var player_chips_path: NodePath
export var enemy_chips_path: NodePath
export var dices_path: NodePath
export var board_path: NodePath

onready var player_chips = get_node(player_chips_path)
onready var enemy_chips = get_node(enemy_chips_path)
onready var dices = get_node(dices_path)
onready var board: Board = get_node(board_path)

var rolled_numbers = []
var rolled_number: int
# Current turn represented as globals.Team enum
var current_turn_owner: int = globals.Team.PLAYER
var currently_rolling: bool = true

func _ready():
	for dice in dices.get_children():
		var val = (dice as Dice).connect("rolled", self, "_on_dice_rolled")
	for chip in player_chips.get_children() + enemy_chips.get_children():
		(chip as Chip).connect("clicked", self, "_chip_clicked")

func _on_dice_rolled(number: int) -> void:
	if not currently_rolling: return
	rolled_numbers.append(number)
	print(rolled_numbers)
	# if all dices were rolled
	if len(rolled_numbers) == dices.get_child_count():
		var sum = 0
		for num in rolled_numbers:
			sum += num
		rolled_numbers.clear()
		rolled_number = sum
		currently_rolling = false
		if sum == 0:
			swap_current_turn_owner()
		else:
			set_teams_chips_clickable(current_turn_owner, true)

func set_teams_chips_clickable(team: int, clickable: bool) -> void:
	var chips = player_chips if team == globals.Team.PLAYER else enemy_chips

	for chip in chips.get_children():
		(chip as Chip).clickable = clickable

func swap_current_turn_owner():
	if current_turn_owner == globals.Team.PLAYER:
		current_turn_owner = globals.Team.ENEMY
	else:
		current_turn_owner = globals.Team.PLAYER

	emit_signal("switch_turn", current_turn_owner)
	currently_rolling = true

func _chip_clicked(chip: Chip):
	if chip.team == current_turn_owner:
		set_teams_chips_clickable(current_turn_owner, false)
		# if the chip isn't placed on the board yet 
		if not board.get_board_object_by_chip(chip):
			(board as Board).spawn_chip(chip)
			rolled_number = max(0, rolled_number - 1)
		
		board.move_x_times(chip, rolled_number)
		chip.global_transform.origin = board.get_board_object_by_chip(chip).get_global_pos() + Vector3(.5, 1, .5)
		swap_current_turn_owner()
