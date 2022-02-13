extends Node
class_name BoardObject

var position: Vector3
var chip: Chip
var grid_map: GridMap 

func _init(_chip: Chip, _position: Vector3, _grid_map: GridMap):
	chip = _chip
	position = _position
	grid_map = _grid_map 

func get_global_pos() -> Vector3:
	return grid_map.transform.xform(position)
