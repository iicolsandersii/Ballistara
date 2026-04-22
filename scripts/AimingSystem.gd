extends Node2D

## Handles mouse-aiming and trajectory-dot preview.
## When the player clicks, emits fire_requested(direction, weapon) so
## GameManager can spawn the projectile and track its settled signal.

signal fire_requested(direction: Vector2, weapon: String)

const DOT_COUNT := 30
const DOT_STEP  := 0.08   # seconds between preview dots

var active: bool = false
var aim_origin: Vector2 = Vector2(200.0, 430.0)
var current_weapon: String = "stone"

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventMouseMotion:
		queue_redraw()
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_do_fire()

func _draw() -> void:
	if not active:
		return

	var mouse_pos := get_global_mouse_position()
	var dir := (mouse_pos - aim_origin).normalized()
	var angle := dir.angle()

	var speed: float
	var grav_scale: float
	if current_weapon == "bolt":
		speed      = 600.0
		grav_scale = 0.3
	else:
		speed      = 400.0
		grav_scale = 1.0

	var g: float = ProjectSettings.get_setting("physics/2d/default_gravity") * grav_scale
	var vx: float = cos(angle) * speed
	var vy: float = sin(angle) * speed

	for i in range(DOT_COUNT):
		var t: float  = i * DOT_STEP
		var dot_pos := Vector2(
			aim_origin.x + vx * t,
			aim_origin.y + vy * t + 0.5 * g * t * t
		)
		var alpha: float = 0.7 * (1.0 - float(i) / float(DOT_COUNT))
		draw_circle(dot_pos, 3.0, Color(1.0, 1.0, 0.0, alpha))

func _do_fire() -> void:
	if not active:
		return
	active = false
	var dir := (get_global_mouse_position() - aim_origin).normalized()
	queue_redraw()
	fire_requested.emit(dir, current_weapon)
