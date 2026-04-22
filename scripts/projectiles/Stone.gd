extends "res://scripts/projectiles/BaseProjectile.gd"

## Catapult stone – slower, full gravity, arcing trajectory.

const STONE_SPEED         := 400.0
const STONE_GRAVITY_SCALE := 1.0

func _ready() -> void:
	gravity_scale = STONE_GRAVITY_SCALE

func _draw() -> void:
	draw_circle(Vector2.ZERO, 8.0, Color(0.55, 0.55, 0.55))
	# Highlight
	draw_circle(Vector2(-2.5, -2.5), 3.0, Color(0.75, 0.75, 0.75))
	# Outline
	draw_circle(Vector2.ZERO, 8.0, Color(0.30, 0.30, 0.30), false, 1.5)
