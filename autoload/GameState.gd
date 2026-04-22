extends Node

## Global game-state singleton (autoloaded as "GameState").
## Holds the current phase, selected weapon, and keep-alive flags
## so every script can read/write them without circular dependencies.

enum Phase {
	BUILD,
	REVEAL,
	BATTLE_PLAYER,
	BATTLE_AI,
	END
}

var current_phase: int = Phase.BUILD
var selected_weapon: String = "stone"   # "stone" | "bolt"
var player_keep_alive: bool = true
var ai_keep_alive: bool = true
