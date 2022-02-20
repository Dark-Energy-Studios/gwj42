extends Node

var button_hover_sound = preload("res://assets/audio/sound/menu_click_1.mp3")
var chip_hover_sound = preload("res://assets/audio/sound/token_hover_1.mp3")

enum Team {
	PLAYER
	ENEMY
}

func team_to_string(team: int) -> String:
	match team:
		Team.PLAYER: return "Player"
		Team.ENEMY: return "Enemy"
		_: return "Unknown"

var first_game:bool = true
var sound_muted:bool = false
