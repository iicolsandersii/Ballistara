extends CanvasLayer

## End screen shown after one side's Keep is destroyed.

@onready var _result_label:  Label  = $Panel/VBox/ResultLabel
@onready var _restart_button: Button = $Panel/VBox/RestartButton

func _ready() -> void:
	_restart_button.pressed.connect(func() -> void: get_tree().reload_current_scene())
	visible = false

func set_result(player_won: bool) -> void:
	if player_won:
		_result_label.text = "VICTORY!\n\nYou destroyed\nthe enemy Keep!"
	else:
		_result_label.text = "DEFEAT!\n\nYour Keep was\ndestroyed…"
