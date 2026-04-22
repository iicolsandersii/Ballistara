extends Control

## Draws the 4×4 placement grid for the Build phase.
## Owned and refreshed by BuildPhase.gd.

const GRID_COLS    := 4
const GRID_ROWS    := 4
const CELL_SIZE    := 40
const GRID_ORIGIN  := Vector2(40, 280)

func _draw() -> void:
	var gw := GRID_COLS * CELL_SIZE
	var gh := GRID_ROWS * CELL_SIZE
	var ox := GRID_ORIGIN.x
	var oy := GRID_ORIGIN.y

	# Background tint for the grid area
	draw_rect(Rect2(ox - 4, oy - 4, gw + 8, gh + 8), Color(0.0, 0.0, 0.0, 0.35))

	# Grid cells
	for gy in range(GRID_ROWS):
		for gx in range(GRID_COLS):
			draw_rect(
				Rect2(ox + gx * CELL_SIZE, oy + gy * CELL_SIZE, CELL_SIZE, CELL_SIZE),
				Color(1.0, 1.0, 1.0, 0.06)
			)

	# Grid lines
	var line_col := Color(1.0, 1.0, 1.0, 0.40)
	for gx in range(GRID_COLS + 1):
		var x := ox + gx * CELL_SIZE
		draw_line(Vector2(x, oy), Vector2(x, oy + gh), line_col, 1.0)
	for gy in range(GRID_ROWS + 1):
		var y := oy + gy * CELL_SIZE
		draw_line(Vector2(ox, y), Vector2(ox + gw, y), line_col, 1.0)
