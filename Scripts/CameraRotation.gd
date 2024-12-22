extends Node3D

@export var rotation_speed: float = 1.0
@export var camera_angle: float = 0
func _process(delta: float) -> void:
	# Rotate around the Y-axis to make the camera orbit the light
	rotation_degrees.y += rotation_speed * delta
	var camera = $Camera3D
	var rotation = Vector3(0, deg_to_rad(camera_angle), 0)
	camera.rotation = rotation
