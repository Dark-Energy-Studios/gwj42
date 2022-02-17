extends Node

enum Team {
	PLAYER
	ENEMY
}

func team_to_string(team: int) -> String:
	match team:
		Team.PLAYER: return "Player"
		Team.ENEMY: return "Enemy"
		_: return "Unknown"
