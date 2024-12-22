extends Panel
@export var player: CharacterBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	player.flower_detected.connect(_on_flower_detected)
	player.flower_not_detected.connect(_on_flower_not_detected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_flower_detected():
	self.visible = true
	
func _on_flower_not_detected():
	self.visible = false
