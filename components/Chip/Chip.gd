extends RigidBody
class_name Chip

signal clicked(chip)

export var clickable: bool
export (globals.Team) var team
export var hover_height: float = 0.1
var hovered: bool = false

var mesh: MeshInstance

func _ready():
	if team == globals.Team.PLAYER:
		$EnemyMesh.queue_free()
		mesh = $PlayerMesh
	else:
		$PlayerMesh.queue_free()
		mesh = $EnemyMesh
		mesh.show()

func _on_Chip_mouse_entered():
	if clickable and not hovered and team == globals.Team.PLAYER:
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
