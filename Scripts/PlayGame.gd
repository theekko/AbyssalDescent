extends Button


@export var player: CharacterBody3D
@export var menu: Control

func _ready():
	self.pressed.connect(self._button_pressed)
	# Ensure the player cannot move at the start
	player.can_move = false
	# Show the menu overlay
	menu.visible = true

# Function to start the game when "Play" is pressed
func _button_pressed():
	print("button pressed")
	# Hide the menu
	menu.visible = false
	# Allow the player to move
	player.can_move = true
	player.mouse_capture = true
