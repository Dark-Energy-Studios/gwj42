extends Spatial

onready var anims

func _ready():
	randomize()
	recreate_anims()
	$Music.play(30.0)
	play_random_anim()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "TRANSITION":
		get_tree().change_scene("res://demo/Main.tscn")
	elif anim_name == "RESET":
		play_random_anim()
	else:
		$AnimationPlayer.play("RESET")

func play_random_anim():
	if len(anims) == 0: recreate_anims()
	var index = randi()%anims.size()
	$AnimationPlayer.play(anims[index])
	anims.remove(index)

func recreate_anims():
	anims = $AnimationPlayer.get_animation_list()
	anims.remove("RESET")
	anims.remove("TRANSITION")


func _on_Button_pressed():
	$AnimationPlayer.play("TRANSITION")
