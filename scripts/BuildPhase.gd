extends CanvasLayer

## Build-phase overlay.
## Shows a semi-transparent panel over the left half of the screen with a
## 4×4 placement grid. Player clicks grid cells to place Wall blocks and one
## Keep, then presses Done.

signal build_done

const GRID_COLS   := 4
const GRID_ROWS   := 4
const CELL_SIZE   := 40
const GRID_ORIGIN := Vector2(40, 280)
const MAX_WALLS   := 12

var _player_fortress: Node = null
var _wall_scene:  PackedScene = null
var _keep_scene:  PackedScene = null
var _placed_positions: Array[Vector2] = []
var _keep_placed: bool = false
var _selected_type: String = "wall"

@onready var _done_button:  Button = $Control/DoneButton
@onready var _wall_button:  Button = $Control/WallButton
@onready var _keep_button:  Button = $Control/KeepButton
@onready var _count_label:  Label  = $Control/CountLabel

func _ready() -> void:
	_wall_scene = load("res://scenes/blocks/WallBlock.tscn")
	_keep_scene = load("res://scenes/blocks/Keep.tscn")
	_done_button.pressed.connect(_on_done_pressed)
	_wall_button.pressed.connect(func() -> void: _set_type("wall"))
	_keep_button.pressed.connect(func() -> void: _set_type("keep"))
	_update_label()
	_refresh_buttons()

## Called by GameManager so this overlay knows where to parent placed blocks.
func setup(player_fortress: Node) -> void:
	_player_fortress = player_fortress

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_try_place(mb.position)

func _try_place(screen_pos: Vector2) -> void:
	var gx := int((screen_pos.x - GRID_ORIGIN.x) / CELL_SIZE)
	var gy := int((screen_pos.y - GRID_ORIGIN.y) / CELL_SIZE)
	if gx < 0 or gx >= GRID_COLS or gy < 0 or gy >= GRID_ROWS:
		return

	var snap := Vector2(
		GRID_ORIGIN.x + gx * CELL_SIZE + CELL_SIZE * 0.5,
		GRID_ORIGIN.y + gy * CELL_SIZE + CELL_SIZE * 0.5
	)
	if snap in _placed_positions:
		return

	if _player_fortress == null:
		return

	if _selected_type == "wall":
		var wall_count := _placed_positions.size() - (1 if _keep_placed else 0)
		if wall_count >= MAX_WALLS:
			return
		var block: RigidBody2D = _wall_scene.instantiate()
		block.set("owner_name", "player")
		block.set("color", Color(0.40, 0.50, 0.65))
		block.position = snap
		_player_fortress.add_child(block)
		_placed_positions.append(snap)

	elif _selected_type == "keep" and not _keep_placed:
		var keep: RigidBody2D = _keep_scene.instantiate()
		keep.set("owner_name", "player")
		keep.position = snap
		_player_fortress.add_child(keep)
		_placed_positions.append(snap)
		_keep_placed = true

	_update_label()

func _set_type(t: String) -> void:
	_selected_type = t
	_refresh_buttons()

func _refresh_buttons() -> void:
	_wall_button.button_pressed = (_selected_type == "wall")
	_keep_button.button_pressed = (_selected_type == "keep")

func _update_label() -> void:
	var wall_count := _placed_positions.size() - (1 if _keep_placed else 0)
	_count_label.text = (
		"Walls: %d / %d\nKeep: %s\nClick grid to place" % [
			wall_count, MAX_WALLS,
			"✓ placed" if _keep_placed else "needed!"
		]
	)

func _on_done_pressed() -> void:
	if not _keep_placed:
		_count_label.text = "Place a Keep first!\n(Select Keep, click grid)"
		return
	visible = false
	build_done.emit()
