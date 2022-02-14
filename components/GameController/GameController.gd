extends Node
class_name GameController

signal switch_turn(turn_owner)

export var player_chips_path: NodePath
export var enemy_chips_path: NodePath
export var board_path: NodePath
export var dice_path: NodePath

onready var player_chips = get_node(player_chips_path)
onready var enemy_chips = get_node(enemy_chips_path)
onready var dice = get_node(dice_path)
onready var board: Board = get_node(board_path)

var rolled_numbers = []
var rolled_number: int
# Current turn represented as globals.Team enum
var current_turn_owner: int = globals.Team.PLAYER
var currently_rolling: bool = true
var opponent_ai = BaseAI.new()

func _ready():
	for die in dice.get_children():
		(die as Die).connect("rolled", self, "_on_dice_rolled")
	for chip in player_chips.get_children() + enemy_chips.get_children():
		(chip as Chip).connect("clicked", self, "_chip_clicked")
	board.connect("kicked_out", self, "_on_kickout")

func _on_kickout(_kicker: Chip, kicked: Chip) -> void:
	kicked.queue_free()

func _on_dice_rolled(number: int) -> void:
	if not currently_rolling: return
	rolled_numbers.append(number)
	print(rolled_numbers)
	# if all dice were rolled
	if len(rolled_numbers) == dice.get_child_count():
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
			if unset_invalid_turns(current_turn_owner, sum):
				swap_current_turn_owner()
			
			if current_turn_owner == globals.Team.ENEMY:
				opponent_ai.make_move(sum, enemy_chips, player_chips)

func set_teams_chips_clickable(team: int, clickable: bool) -> void:
	var chips = player_chips if team == globals.Team.PLAYER else enemy_chips

	for chip in chips.get_children():
		(chip as Chip).clickable = clickable

# makes the chips that can't be moved unclickable
# and returns wether ALL are
func unset_invalid_turns(team: int, number: int) -> bool:
	var chips = player_chips if team == globals.Team.PLAYER else enemy_chips
	var at_least_one_clickable: bool = false

	for chip in chips.get_children():
		var obj = board.get_board_object_by_chip(chip)
		if not obj:
			var spawn_point: Vector3
			if team == globals.Team.PLAYER:
				spawn_point = board.get_fields(Board.Field.PLAYER_START)[0]
			else:
				spawn_point = board.get_fields(Board.Field.ENEMY_START)[0]
			
			if board.is_field_occupied(spawn_point):
				chip.clickable = false
			else:
				at_least_one_clickable = true
		else:
			var new_pos = obj.position
			for _i in range(number):
				new_pos += board.get_direction_from_field(board.get_field_by_vec(new_pos), team)
			if board.get_move_action(obj, new_pos) == Board.Action.STAY:
				chip.clickable = false
			else:
				at_least_one_clickable = true

	return not at_least_one_clickable

func swap_current_turn_owner():
	if current_turn_owner == globals.Team.PLAYER:
		current_turn_owner = globals.Team.ENEMY
	else:
		current_turn_owner = globals.Team.PLAYER

	emit_signal("switch_turn", current_turn_owner)
	currently_rolling = true
	
	if current_turn_owner == globals.Team.ENEMY:
		yield(get_tree().create_timer(2.0), "timeout")
		roll_dice()

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

func roll_dice():
		for die in dice.get_children():
			die.reset()
