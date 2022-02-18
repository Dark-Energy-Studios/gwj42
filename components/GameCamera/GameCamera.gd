extends Position3D
class_name GameCamera

export var current: bool = true setget set_current, get_current
export(float, 0.5, 10.0, 0.5) var rotation_speed = 1
export var invert_y: bool = false
export(float, 1, 15, 0.5) var distance = 1
export(float, 1, 15, 0.5) var height = 1
export var fov: float setget set_fov

onready var default_cam = get_node("DefaultCamera")
onready var top_down_cam = get_node("TopDownCamera")

func set_fov(val):
	$DefaultCamera.fov = val

func set_current(val):
	default_cam.current = val

func get_current():
	return default_cam.current

func _ready():
	default_cam.fov = fov
	default_cam.current = current
	default_cam.transform.origin = Vector3(0, height, distance)
	top_down_cam.transform.origin = Vector3(0, height, 0)

func move_cam(movement: Vector2):
	default_cam.transform.origin.y += deg2rad(movement.y * rotation_speed) * (-1 if !invert_y else 1)
	default_cam.transform.origin.z -= deg2rad(movement.y * rotation_speed) * (-1 if !invert_y else 1)
	default_cam.transform.origin.y = clamp(default_cam.transform.origin.y * (-1 if invert_y else 1), 1.9, height)
	default_cam.transform.origin.z = clamp(default_cam.transform.origin.z * (-1 if invert_y else 1), .5, distance)
	rotation.y += -deg2rad(movement.x * rotation_speed)

func _input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("right_click") and default_cam.current:
		move_cam(event.relative)
		
	elif Input.is_action_pressed("switch_camera"):
		if default_cam.current:
			top_down_cam.make_current()
			rotation_degrees = Vector3.ZERO
		else:
			default_cam.make_current()


func _process(delta):
	default_cam.look_at(global_transform.origin, Vector3.UP)
	if Input.is_action_pressed("arrow_keys"):
		move_cam(Vector2(
			(int(Input.is_action_pressed("ui_left")) - int(Input.is_action_pressed("ui_right"))) * 2,
			(int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))) * 2
		))
