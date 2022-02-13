extends StaticBody

signal kicked_out(kicking_obj, kicked_obj)

# TODO: Replace enum values with actual field values
enum Field {
	EMPTY = -1
	PLAYER_START = 1
	ENEMY_START
	SPECIAL = 7
	END = 8
}

enum Action {
	ERROR = -1
	MOVE
	STAY
	KICK_OUT
}

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

# Get the type of a field by its coordinates
func get_field(x: float, y: float, z: float) -> int:
	return $GridMap.get_cell_item(x, y, z)

# Get the type of a field by its vector
func get_field_by_vec(vector: Vector3) -> int:
	return get_field(vector.x, vector.y, vector.z)

# Spawn a player object at the Field.PLAYER_START field
func spawn_player_object(player) -> bool:
	var spawn_point = get_fields(Field.PLAYER_START)
	for obj in board_objects:
		if obj.position == spawn_point:
			return false
	board_objects.append(BoardObject.new(true, player, spawn_point[0], $GridMap))
	return true

# Spawn an enemy object at the Field.ENEMY_START field
func spawn_enemy_object(enemy) -> bool:
	var spawn_point = get_fields(Field.ENEMY_START)
	for obj in board_objects:
		if obj.position == spawn_point:
			return false
	board_objects.append(BoardObject.new(false, enemy, spawn_point, $GridMap))
	return true

func remove_board_object(chip) -> void:
	board_objects.erase(get_board_object_by_chip(chip))

func get_direction_from_field(field: int, is_player: bool) -> Vector3:
	var directions ={
		0: Vector3(0, 0, 1),
		1: Vector3(0, 0, -1),
		2: Vector3(-1, 0, 0) if is_player else Vector3(1, 0, 0),
		3: Vector3(1, 0, 0) if is_player else Vector3(-1, 0, 0),
		4: Vector3(0, 0, -1),
		5: Vector3(0, 0, -1),
		6: Vector3(0, 0, -1),
		7: Vector3(0, 0, -1),
		8: Vector3(0, 0, 1)
	}
	return directions[field]

# Get the action that is happening when a certain object wants to do
# a certain move
func get_move_action(moving_obj: BoardObject, new_coords: Vector3) -> int:
	for obj in board_objects:
		if obj == moving_obj: continue
		if obj.position == new_coords:
			if get_field_by_vec(obj.position) != Field.SPECIAL and obj.is_player != moving_obj.is_player:
				return Action.KICK_OUT
			else:
				return Action.STAY

	return Action.MOVE

# Request a certain move for a certain object

func _ready():
	print(spawn_player_object("Something"))

func _on_Timer_timeout():
	move_x_times("Something", 3)
	var obj = get_board_object_by_chip("Something")
	$MeshInstance.global_transform.origin = obj.get_global_pos() + Vector3(.5, .5, .5)

# Returns an Action
func request_move(chip, new_coords: Vector3) -> int:
	var obj = get_board_object_by_chip(chip)
	if not obj:
		return Action.ERROR

	var action = get_move_action(obj, new_coords)
	if action == Action.KICK_OUT:
		emit_signal("kicked_out", chip, get_board_object_by_coords(new_coords).chip)
	elif action == Action.MOVE:
		obj.position = new_coords

	return action

func move_x_times(chip, x: int):
	var obj = get_board_object_by_chip(chip)
	var new_pos = obj.position
	for _i in range(x):
		new_pos += get_direction_from_field(get_field_by_vec(new_pos), obj.is_player)
	request_move("Something", new_pos)
