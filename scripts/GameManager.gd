extends Node

## Central state-machine node (child of Main.tscn).
## Drives the BUILD → REVEAL → BATTLE_PLAYER ↔ BATTLE_AI → END flow.

@onready var _game        = $Game
@onready var _build_phase = $BuildPhase
@onready var _battle_hud  = $BattleHUD
@onready var _end_screen  = $EndScreen
@onready var _aiming      = $AimingSystem
@onready var _ai          = $AIController

var _player_keep: Node = null
var _ai_keep:     Node = null
var _phase: int = GameState.Phase.BUILD

func _ready() -> void:
	# Reset global state so restarts are clean
	GameState.selected_weapon     = "stone"
	GameState.player_keep_alive   = true
	GameState.ai_keep_alive       = true
	# Wire build-phase
	_build_phase.setup(_game.player_fortress)
	_build_phase.build_done.connect(_on_build_done)
	# Wire aiming
	_aiming.fire_requested.connect(_on_fire_requested)
	# Generate AI fortress (hidden behind concealment)
	_setup_ai_fortress()
	# Start in build phase
	_enter_build()

# ---------------------------------------------------------------------------
# AI setup
# ---------------------------------------------------------------------------

func _setup_ai_fortress() -> void:
	var keep_scene: PackedScene = load("res://scenes/blocks/Keep.tscn")
	var wall_scene: PackedScene = load("res://scenes/blocks/WallBlock.tscn")
	_ai_keep = _ai.generate_fortress(_game.ai_fortress, keep_scene, wall_scene)
	if _ai_keep != null:
		_ai_keep.keep_destroyed.connect(_on_keep_destroyed.bind("ai"))

# ---------------------------------------------------------------------------
# Phase: BUILD
# ---------------------------------------------------------------------------

func _enter_build() -> void:
	_phase = GameState.Phase.BUILD
	GameState.current_phase = _phase
	_build_phase.visible = true
	_battle_hud.visible  = false
	_end_screen.visible  = false
	_aiming.active       = false
	_game.freeze_all_blocks()

func _on_build_done() -> void:
	# Find the Keep the player placed and connect to its signal
	for block in _game.player_fortress.get_children():
		if block.get_script() != null:
			if "Keep" in block.get_script().resource_path:
				_player_keep = block
				_player_keep.keep_destroyed.connect(
					_on_keep_destroyed.bind("player"))
				break
	_enter_reveal()

# ---------------------------------------------------------------------------
# Phase: REVEAL
# ---------------------------------------------------------------------------

func _enter_reveal() -> void:
	_phase = GameState.Phase.REVEAL
	GameState.current_phase = _phase
	_build_phase.visible = false
	_battle_hud.visible  = true
	_game.reveal_ai()
	_game.unfreeze_all_blocks()
	await get_tree().create_timer(1.5).timeout
	_enter_battle_player()

# ---------------------------------------------------------------------------
# Phase: BATTLE_PLAYER
# ---------------------------------------------------------------------------

func _enter_battle_player() -> void:
	_phase = GameState.Phase.BATTLE_PLAYER
	GameState.current_phase = _phase
	_battle_hud.set_turn("Your Turn  —  Aim & click to fire")
	_aiming.aim_origin    = Vector2(200.0, 428.0)
	_aiming.current_weapon = GameState.selected_weapon
	_aiming.active        = true
	_aiming.queue_redraw()

func _on_fire_requested(direction: Vector2, weapon: String) -> void:
	# Spawn projectile
	var speed := 600.0 if weapon == "bolt" else 400.0
	var proj := _game.spawn_projectile(weapon, _aiming.aim_origin, direction * speed)
	proj.projectile_settled.connect(_on_player_projectile_settled)

func _on_player_projectile_settled() -> void:
	if not GameState.ai_keep_alive:
		_enter_end(true)
	else:
		_enter_battle_ai()

# ---------------------------------------------------------------------------
# Phase: BATTLE_AI
# ---------------------------------------------------------------------------

func _enter_battle_ai() -> void:
	_phase = GameState.Phase.BATTLE_AI
	GameState.current_phase = _phase
	_battle_hud.set_turn("AI Turn…")
	_aiming.active = false
	await get_tree().create_timer(1.0).timeout
	_do_ai_fire()

func _do_ai_fire() -> void:
	var target := Vector2(120.0, 420.0)
	if _player_keep != null and is_instance_valid(_player_keep):
		target = _player_keep.global_position
	elif _game.player_fortress.get_child_count() > 0:
		target = _game.player_fortress.get_child(0).global_position

	var shot   := _ai.compute_shot(target, GameState.selected_weapon)
	var proj   := _game.spawn_projectile(
		shot["weapon"], shot["from"], shot["velocity"])
	proj.projectile_settled.connect(_on_ai_projectile_settled)

func _on_ai_projectile_settled() -> void:
	if not GameState.player_keep_alive:
		_enter_end(false)
	else:
		_enter_battle_player()

# ---------------------------------------------------------------------------
# Win condition
# ---------------------------------------------------------------------------

func _on_keep_destroyed(owner_name: String) -> void:
	if owner_name == "player":
		GameState.player_keep_alive = false
		_enter_end(false)
	else:
		GameState.ai_keep_alive = false
		_enter_end(true)

# ---------------------------------------------------------------------------
# Phase: END
# ---------------------------------------------------------------------------

func _enter_end(player_won: bool) -> void:
	_phase = GameState.Phase.END
	GameState.current_phase = _phase
	_aiming.active = false
	_end_screen.set_result(player_won)
	_end_screen.visible = true
