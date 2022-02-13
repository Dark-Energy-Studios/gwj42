extends Node
class_name BoardObject

var is_player: bool
var position: Vector3
var chip
var grid_map: GridMap 

func _init(_is_player: bool, _chip, _position: Vector3, _grid_map: GridMap):
	is_player = _is_player
	chip = _chip
	position = _position
	grid_map = _grid_map 

func get_global_pos():
	return grid_map.transform.xform(position)
