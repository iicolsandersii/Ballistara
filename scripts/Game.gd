extends Node2D

## Arena root.  Draws sky, ground, platforms.
## Owns PlayerFortress, AIFortress, AIConcealment, ProjectileContainer.

const _SKY_COLOR      := Color(0.53, 0.81, 0.98)
const _GROUND_COLOR   := Color(0.22, 0.48, 0.22)
const _PLATFORM_COLOR := Color(0.32, 0.26, 0.20)

@onready var player_fortress:     Node2D   = $PlayerFortress
@onready var ai_fortress:         Node2D   = $AIFortress
@onready var ai_concealment:      ColorRect = $AIConcealment
@onready var projectile_container: Node2D  = $ProjectileContainer

var _bolt_scene:  PackedScene = null
var _stone_scene: PackedScene = null

func _ready() -> void:
	_bolt_scene  = load("res://scenes/projectiles/Bolt.tscn")
	_stone_scene = load("res://scenes/projectiles/Stone.tscn")

# ---------------------------------------------------------------------------

func freeze_all_blocks() -> void:
	_set_frozen(player_fortress, true)
	_set_frozen(ai_fortress,     true)

func unfreeze_all_blocks() -> void:
	_set_frozen(player_fortress, false)
	_set_frozen(ai_fortress,     false)

func _set_frozen(fortress: Node, frozen: bool) -> void:
	for block in fortress.get_children():
		if block is RigidBody2D:
			block.freeze = frozen

# ---------------------------------------------------------------------------

func reveal_ai() -> void:
	create_tween().tween_property(
		ai_concealment, "position", Vector2(800.0, 0.0), 0.6
	).set_ease(Tween.EASE_IN)

# ---------------------------------------------------------------------------

func spawn_projectile(weapon: String, origin: Vector2,
		velocity: Vector2) -> RigidBody2D:
	var scene: PackedScene = _bolt_scene if weapon == "bolt" else _stone_scene
	var proj: RigidBody2D  = scene.instantiate()
	proj.position = origin
	projectile_container.add_child(proj)
	proj.call("launch", velocity)
	return proj

# ---------------------------------------------------------------------------

func _draw() -> void:
	# Sky
	draw_rect(Rect2(0, 0, 800, 600), _SKY_COLOR)
	# Ground strip
	draw_rect(Rect2(0, 550, 800, 50), _GROUND_COLOR)
	# Left platform
	draw_rect(Rect2(20, 440, 220, 20), _PLATFORM_COLOR)
	# Right platform
	draw_rect(Rect2(560, 440, 220, 20), _PLATFORM_COLOR)
	# Subtle centre divider
	draw_line(Vector2(400, 0), Vector2(400, 550), Color(0.0, 0.0, 0.0, 0.07), 1.5)
