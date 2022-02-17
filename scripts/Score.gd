extends GridContainer

signal stones_changed(num)

export(Texture) var color
const Blank = preload("res://assets/visual/Stone_Blank.png")

func _ready():
	connect("stones_changed", self, "update_ui")
	reset_score()
	
func update_ui(num):
	for i in range(1, num+1):
		get_node("Stone-" + str(i)).texture = color

func reset_score():
	for i in range(1, 8):
		get_node("Stone-" + str(i)).texture = Blank
