extends CanvasLayer

## Battle HUD – shows whose turn it is and lets the player switch weapons.

@onready var _turn_label:   Label  = $Control/TurnLabel
@onready var _weapon_label: Label  = $Control/WeaponLabel
@onready var _stone_button: Button = $Control/StoneButton
@onready var _bolt_button:  Button = $Control/BoltButton

func _ready() -> void:
	_stone_button.pressed.connect(func() -> void: _select("stone"))
	_bolt_button.pressed.connect( func() -> void: _select("bolt"))
	_refresh()
	visible = false

func set_turn(text: String) -> void:
	_turn_label.text = text

func _select(weapon: String) -> void:
	GameState.selected_weapon = weapon
	_refresh()

func _refresh() -> void:
	var w := GameState.selected_weapon
	_weapon_label.text    = "Weapon: " + ("Catapult Stone" if w == "stone" else "Crossbow Bolt")
	_stone_button.button_pressed = (w == "stone")
	_bolt_button.button_pressed  = (w == "bolt")
