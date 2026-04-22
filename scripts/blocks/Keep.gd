extends RigidBody2D

## Fortress Keep – the win-condition block.
## Emits keep_destroyed when it falls off the platform (y > 520) during battle.

signal keep_destroyed(p_owner: String)

const BLOCK_SIZE := 40

var owner_name: String = "player"
var color: Color = Color(0.2, 0.3, 0.8)

const FALL_OFF_THRESHOLD := 520.0

func _ready() -> void:
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

func _process(_delta: float) -> void:
	if global_position.y > FALL_OFF_THRESHOLD and not freeze:
		keep_destroyed.emit(owner_name)
		queue_free()

func _draw() -> void:
	var h := BLOCK_SIZE * 0.5
	# Main body
	draw_rect(Rect2(-h, -h, BLOCK_SIZE, BLOCK_SIZE), color)
	# Left battlement
	draw_rect(Rect2(-h - 4.0, -h - 14.0, 12.0, 14.0), color)
	# Right battlement
	draw_rect(Rect2(h - 8.0,  -h - 14.0, 12.0, 14.0), color)
	# Outline
	draw_rect(Rect2(-h, -h, BLOCK_SIZE, BLOCK_SIZE), Color(0.0, 0.0, 0.0, 0.55), false, 2.0)
