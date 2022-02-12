extends StaticBody

# Replace enum values with actual field values
enum Field {
	START = 1
	SAFE = 7
	END = 8
}

# Get the coordinates of certain fields
func get_fields(field_type: int) -> Array:
	var cells = []

	for cell_coords in $GridMap.get_used_cells():
		var cell = $GridMap.get_cell_item(cell_coords.x, cell_coords.y, cell_coords.z)
		if cell == field_type:
			cells.append(cell_coords)

	return cells
