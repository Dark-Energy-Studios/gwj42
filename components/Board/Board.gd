extends StaticBody
class_name Board

signal kicked_out(kicking_chip, kicked_chip)

# TODO: Replace enum values with actual field values
enum Field {
	EMPTY = -1
	PLAYER_START = 1
	ENEMY_START = 9
	SPECIAL = 7
	END = 8
}

enum Action {
	ERROR = -1
	MOVE
	STAY
	KICK_OUT
}

class Move:
	var action: int
	var field: int
	
	func _init(action, field):
		self.action = action
		self.field = field
	static func EMPTY() -> Move:
		return Move.new(Action.ERROR, Field.EMPTY)
	static func DO_SOMETHING() -> Move:
		return Move.new(Action.MOVE, Field.EMPTY)

var board_objects := []

func get_board_object_by_chip(chip):
	for obj in board_objects:
		if obj.chip == chip:
			return obj
	return null

func get_board_object_by_coords(coords: Vector3):
	for obj in board_objects:
		if obj.position == coords: 
			return obj
	return null

func get_all_fields() -> Array:
	return $GridMap.get_used_cells()

# Get the coordinates of certain fields
func get_fields(field_type: int) -> Array:
	var cells = []

	for cell_coords in get_all_fields():
		var cell = $GridMap.get_cell_item(cell_coords.x, cell_coords.y, cell_coords.z)
		if cell == field_type:
			cells.append(cell_coords)

	return cells

func is_field_occupied(coords: Vector3) -> bool:
	for obj in board_objects:
		if obj.position == coords:
			return true
	return false

# Get the type of a field by its coordinates
func get_field(x: float, y: float, z: float) -> int:
	return $GridMap.get_cell_item(x, y, z)

# Get the type of a field by its vector
func get_field_by_vec(coords: Vector3) -> int:
	return get_field(coords.x, coords.y, coords.z)

# Spawn a chip in the board system
func spawn_chip(chip: Chip) -> bool:
	var spawn_point: Array#<Vector3>
	if chip.team == globals.Team.PLAYER:
		spawn_point = get_fields(Field.PLAYER_START)
	else:
		spawn_point = get_fields(Field.ENEMY_START)

	for obj in board_objects:
		if obj.position == spawn_point[0]:
			return false

	board_objects.append(BoardObject.new(chip, spawn_point[0], $GridMap))
	return true

func remove_board_object(chip) -> void:
	board_objects.erase(get_board_object_by_chip(chip))

func get_direction_from_field(field: int, team: int) -> Vector3:
	var directions ={
		0: Vector3(0, 0, 1),
		1: Vector3(0, 0, -1),
		2: Vector3(-1, 0, 0) if team == globals.Team.PLAYER else Vector3(1, 0, 0),
		3: Vector3(1, 0, 0) if team == globals.Team.PLAYER else Vector3(-1, 0, 0),
		4: Vector3(0, 0, -1),
		5: Vector3(0, 0, -1),
		6: Vector3(0, 0, -1),
		7: Vector3(0, 0, 1),
		8: Vector3(0, 0, 1),
		9: Vector3(0, 0, -1)
	}
	return directions[field]

# Get the action that is happening when a certain object wants to do
# a certain move
func get_move_action(moving_obj: BoardObject, new_coords: Vector3) -> Move:
	var new_field = get_field_by_vec(new_coords)
	for obj in board_objects:
		if obj == moving_obj: continue
		if obj.position == new_coords:
			if new_field != Field.SPECIAL and obj.chip.team != moving_obj.chip.team:
				return Move.new(Action.KICK_OUT, new_field)
			else:
				return Move.new(Action.STAY, new_field)

	return Move.new(Action.MOVE, new_field)

# Request a certain move for a certain object
# Returns an Action
func request_move(chip: Chip, new_coords: Vector3) -> Move:
	var obj = get_board_object_by_chip(chip)
	if not obj:
		return Move.EMPTY
		
	var move = get_move_action(obj, new_coords)
	if move.action == Action.KICK_OUT:
		var kicked_chip = get_board_object_by_coords(new_coords).chip
		emit_signal("kicked_out", chip, kicked_chip)
		obj.position = new_coords
		remove_board_object(kicked_chip)
	elif move.action == Action.MOVE:
		obj.position = new_coords

	return move

# Returns an Action
func move_x_times(chip, x: int) -> Move:
	var obj = get_board_object_by_chip(chip)
	var new_pos = obj.position
	for _i in range(x):
		new_pos += get_direction_from_field(get_field_by_vec(new_pos), chip.team)

	return request_move(chip, new_pos)
