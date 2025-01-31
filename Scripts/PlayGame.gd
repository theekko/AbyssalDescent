extends Button


@export var player: CharacterBody3D
@export var menu: Control

func _ready():
	self.pressed.connect(self._button_pressed)
	player.can_move = false
	menu.visible = true

func _button_pressed():
	print("button pressed")
	menu.visible = false
	player.can_move = true
	player.mouse_capture = true
