extends RigidBody
class_name Chip

signal clicked(chip)

export var clickable: bool
export (globals.Team) var team
export (int) var position = -1
export var hover_height: float = 0.1
export var move_height: float = 0.5
var hovered: bool = false

var mesh: MeshInstance

# if chip is kicked-off the board by the opponent, 
# the chip should return to its initial position
var initial_position:Transform

func _ready():
	if team == globals.Team.PLAYER:
		$EnemyMesh.queue_free()
		mesh = $PlayerMesh
	else:
		$PlayerMesh.queue_free()
		mesh = $EnemyMesh
		mesh.show()

	initial_position = self.global_transform

func reset():
	self.global_transform = initial_position
	self.position = -1
	set_sleeping(false)

func move(target_index:int, target_position:Vector3):
	self.global_transform.origin = target_position
	self.position = target_index
	set_sleeping(false)

func _on_Chip_mouse_entered():
	if clickable and not hovered:
		mesh.global_transform.origin += Vector3(0, hover_height, 0)
		set_sleeping(true)
		hovered = true

func _process(_delta):
	if Input.is_action_just_pressed("left_click") and clickable and hovered:
		emit_signal("clicked", self)

func _on_Chip_mouse_exited():
	if hovered:
		mesh.global_transform.origin -= Vector3(0, hover_height, 0)
		set_sleeping(false)
		hovered = false
