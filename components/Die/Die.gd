extends RigidBody
class_name Die

signal rolled(number)

var initial_position

func _ready():
	initial_position = global_transform.origin
	
func get_rolled_number():
	var highest_point: Position3D = null
	for point in [$WhitePoint1, $WhitePoint2, $EmptyPoint1, $EmptyPoint2]:
		if not highest_point or point.global_transform.origin.y > highest_point.global_transform.origin.y:
			highest_point = point

	return 1 if highest_point.name.begins_with("White") else 0

func _on_Dice_sleeping_state_changed():
	if is_sleeping():
		emit_signal("rolled", get_rolled_number())

func reset():
	# Set Position
	global_transform.origin = initial_position
	
	# Random Angle (or more specifically a fixed angle on a random axis)
	randomize()
	var axis = Vector3(randf(), randf(), randf()).normalized()
	global_rotate(axis, 3.14)
	
	set_sleeping(false)
