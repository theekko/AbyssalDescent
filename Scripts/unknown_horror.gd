extends Panel
@export var player: CharacterBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	player.unknown_horror_detected.connect(_on_unknown_horror_detected)
	player.unknown_horror_not_detected.connect(_on_unknown_horror_not_detected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_unknown_horror_detected():
	self.visible = true
	
func _on_unknown_horror_not_detected():
	self.visible = false
