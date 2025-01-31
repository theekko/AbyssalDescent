extends Panel
@export var player: CharacterBody3D



func _ready() -> void:
	self.visible = false
	player.unknown_horror_detected.connect(_on_unknown_horror_detected)
	player.unknown_horror_not_detected.connect(_on_unknown_horror_not_detected)

func _on_unknown_horror_detected():
	self.visible = true
	
func _on_unknown_horror_not_detected():
	self.visible = false
