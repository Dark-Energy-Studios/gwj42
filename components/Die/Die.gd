extends RigidBody
class_name Die

signal rolled()

var initial_position
var number
var roll_finished:bool = false

func _ready():
	initial_position = global_transform.origin
	
func get_rolled_number():
	var highest_point: Position3D = null
	for point in [$WhitePoint1, $WhitePoint2, $EmptyPoint1, $EmptyPoint2]:
		if not highest_point or point.global_transform.origin.y > highest_point.global_transform.origin.y:
			highest_point = point

	return 1 if highest_point.name.begins_with("White") else 0

func _on_Dice_sleeping_state_changed():
	if is_sleeping() and !roll_finished:
		number = get_rolled_number()
		roll_finished = true
		emit_signal("rolled")

func roll():
	# Set Position
	global_transform.origin = initial_position
	
	# Random Angle (or more specifically a fixed angle on a random axis)
	randomize()
	var axis = Vector3(randf(), randf(), randf()).normalized()
	global_rotate(axis, 3.14)
	
	roll_finished = false
	set_sleeping(false)
	# emit_signal("rolled", randi() % 2)
