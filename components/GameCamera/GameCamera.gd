extends Position3D

export var current: bool = true setget set_current, get_current
export(float, 0.5, 10.0, 0.5) var rotation_speed = 1
export var distance: float = 1
export var height: float = 1
export var fov: float setget set_fov

func set_fov(val):
	$Camera.fov = val

func set_current(val):
	$Camera.current = val

func get_current():
	return $Camera.current

func _ready():
	$Camera.fov = fov
	$Camera.current = current
	$Camera.transform.origin = Vector3(0, height, distance)
	
func _process(delta):
	$Camera.look_at(global_transform.origin, Vector3.UP)
	if Input.is_action_pressed("ui_right"):
		rotate_y(rotation_speed*delta)
	elif Input.is_action_pressed("ui_left"):
		rotate_y(-rotation_speed*delta)
