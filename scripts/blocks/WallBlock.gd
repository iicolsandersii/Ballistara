extends RigidBody2D

## A single 40×40 wall block.
## Frozen (kinematic) during build; unfrozen at battle start so it can tumble.

const BLOCK_SIZE := 40

var owner_name: String = "player"
var color: Color = Color(0.4, 0.5, 0.65)

func _ready() -> void:
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

func _draw() -> void:
	var h := BLOCK_SIZE * 0.5
	draw_rect(Rect2(-h, -h, BLOCK_SIZE, BLOCK_SIZE), color)
	draw_rect(Rect2(-h, -h, BLOCK_SIZE, BLOCK_SIZE), Color(0.0, 0.0, 0.0, 0.3), false, 2.0)
