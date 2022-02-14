extends RigidBody
class_name Dice

signal rolled(number)

func get_rolled_number():
	var highest_point: Position3D = null
	for point in [$WhitePoint1, $WhitePoint2, $EmptyPoint1, $EmptyPoint2]:
		if not highest_point or point.global_transform.origin.y > highest_point.global_transform.origin.y:
			highest_point = point

	return 1 if highest_point.name.begins_with("White") else 0


func _on_Dice_sleeping_state_changed():
	if is_sleeping():
		emit_signal("rolled", get_rolled_number())
