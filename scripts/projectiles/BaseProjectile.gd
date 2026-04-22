extends RigidBody2D

## Base class for all projectiles.
## Call launch(velocity) after adding to the scene tree.
## Emits projectile_settled when motion stops or the projectile leaves the arena.

signal projectile_settled

const SETTLE_TIME     := 3.0   # seconds before auto-settling
const OUT_OF_BOUNDS_Y := 700.0

var _settle_timer: float = 0.0
var _settled: bool = false

func launch(velocity: Vector2) -> void:
	linear_velocity = velocity

func _physics_process(delta: float) -> void:
	if _settled:
		return
	_settle_timer += delta
	var oob: bool = (
		global_position.y > OUT_OF_BOUNDS_Y or
		global_position.x < -60.0 or
		global_position.x > 860.0
	)
	if _settle_timer >= SETTLE_TIME or oob:
		_settle()

func _settle() -> void:
	_settled = true
	projectile_settled.emit()
	queue_free()
