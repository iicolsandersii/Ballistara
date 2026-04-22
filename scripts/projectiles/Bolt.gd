extends "res://scripts/projectiles/BaseProjectile.gd"

## Crossbow bolt – fast, low gravity, flat trajectory.

const BOLT_SPEED         := 600.0
const BOLT_GRAVITY_SCALE := 0.3

func _ready() -> void:
	gravity_scale = BOLT_GRAVITY_SCALE

func _draw() -> void:
	# Shaft
	draw_rect(Rect2(-13.0, -3.0, 26.0, 6.0), Color(0.80, 0.60, 0.20))
	# Tip
	draw_circle(Vector2(13.0, 0.0), 3.5, Color(0.90, 0.75, 0.30))
