extends Node

## AI opponent logic:
##   • generate_fortress()  – procedurally builds the right-side fortress
##   • compute_shot()       – calculates a ballistic firing solution + inaccuracy
##
## Coordinate notes (Godot y-down):
##   Gravity is +y (downward).  "Upward" velocity has negative vy.
##   The arc solver works in a "rightward frame" (positive dx), then the
##   final velocity is mirrored to fire leftward toward the player.

var ai_accuracy: float = 0.70   # 0..1; increases after each shot

# ---------------------------------------------------------------------------
# Fortress generation
# ---------------------------------------------------------------------------

func generate_fortress(fortress_node: Node, keep_scene: PackedScene,
		wall_scene: PackedScene) -> Node:
	for child in fortress_node.get_children():
		child.queue_free()

	var base_x := 620.0
	var base_y := 440.0
	var bs     := 40.0

	# L-shaped wall layout (column positions relative to base)
	var layout: Array = [
		Vector2(0, 0), Vector2(1, 0), Vector2(2, 0),
		Vector2(0, -1),               Vector2(2, -1),
		Vector2(0, -2),               Vector2(2, -2),
	]

	for cell in layout:
		var block: RigidBody2D = wall_scene.instantiate()
		block.set("owner_name", "ai")
		block.set("color", Color(0.60, 0.28, 0.18))
		block.position = Vector2(base_x + cell.x * bs, base_y + cell.y * bs)
		fortress_node.add_child(block)

	var keep: RigidBody2D = keep_scene.instantiate()
	keep.set("owner_name", "ai")
	keep.set("color", Color(0.75, 0.15, 0.10))
	keep.position = Vector2(base_x + bs, base_y - 3.0 * bs)
	fortress_node.add_child(keep)
	return keep

# ---------------------------------------------------------------------------
# Ballistic arc solver  (correct for Godot y-down coordinates)
# ---------------------------------------------------------------------------
#
# Derivation (y-down, gravity = +g):
#   x(t) = vx*t
#   y(t) = vy*t + 0.5*g*t²   (vy negative = upward)
#
# Solving for the RIGHTWARD-FIRING case (dx_abs > 0) gives:
#   discriminant = v⁴ – g²·dx_abs² + 2·g·dy_down·v²
#   angle        = atan2(v² – sqrt(disc), g·dx_abs)   [y-UP convention]
#   vx_right     = cos(angle)·v
#   vy_up        = sin(angle)·v      → vy_screen = –vy_up
#
# We then mirror horizontally to fire LEFT: vx = –vx_right.

func _solve(dx_abs: float, dy_down: float, v: float, g: float) -> Vector2:
	# Returns (vx_rightward, vy_upward) in y-UP convention.
	# Caller converts to Godot screen coords.
	var disc: float = v*v*v*v - g*g*dx_abs*dx_abs + 2.0*g*dy_down*v*v
	if disc >= 0.0:
		var angle := atan2(v*v - sqrt(disc), g * dx_abs)
		return Vector2(cos(angle) * v, sin(angle) * v)
	# Out of range – lob at 45 °
	return Vector2(v * 0.7071068, v * 0.7071068)

## Returns a dict { from, velocity, weapon } ready for Game.spawn_projectile().
func compute_shot(target: Vector2, weapon: String) -> Dictionary:
	var from_pos := Vector2(580.0, 420.0)
	var speed    := 600.0 if weapon == "bolt" else 400.0
	var gscale   := 0.3   if weapon == "bolt" else 1.0
	var g: float  = ProjectSettings.get_setting("physics/2d/default_gravity") * gscale

	var dx_abs   := absf(target.x - from_pos.x)
	var dy_down  := target.y - from_pos.y   # positive = target is below origin

	var aim := _solve(dx_abs, dy_down, speed, g)
	# aim.x = rightward component, aim.y = upward component (y-UP)

	# Apply angular inaccuracy
	var spread := 0.15 * (1.0 - ai_accuracy)
	var err    := randf_range(-spread, spread)
	var c := cos(err);  var s := sin(err)
	var ax := aim.x * c - aim.y * s
	var ay := aim.x * s + aim.y * c

	# Mirror to fire leftward; convert y-UP → y-DOWN (Godot screen)
	var vx := -ax          # negative = leftward
	var vy := -ay          # negative = upward in screen

	ai_accuracy = minf(ai_accuracy + 0.03, 0.95)

	return {
		"from":     from_pos,
		"velocity": Vector2(vx, vy),
		"weapon":   weapon,
	}
