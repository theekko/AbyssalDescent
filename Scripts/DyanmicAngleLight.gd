extends OmniLight3D

@export var camera: Camera3D  # Reference to the camera
@export var player: CharacterBody3D  # Reference to the player
@export var max_light_range = 30.0  # Maximum brightness at the center
@export var min_light_range = 5.0  # Minimum brightness at the edges
@export var max_distance = 100.0  # Distance at which the light starts dimming
@export var min_distance_factor = 0.3  # 50% of max distance
@export var threshold = 80.0
@export var above_threshold_range_value = 50.0

# Called every frame
func _physics_process(delta: float) -> void:
	# Get the light's position in the camera's frustum (viewport space)
	var light_screen_pos = camera.unproject_position(global_transform.origin)

	# Get the size of the viewport (the screen space)
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Normalize the light's position in the screen (0,0 is center, 1,1 is the edge)
	var normalized_pos = Vector2(
		abs(light_screen_pos.x - viewport_size.x / 2) / (viewport_size.x / 2),
		abs(light_screen_pos.y - viewport_size.y / 2) / (viewport_size.y / 2)
	)

	# Use the distance from the center of the screen to adjust brightness
	var distance_from_center = max(normalized_pos.x, normalized_pos.y)

	# Calculate the distance between the player and the light
	var player_distance = global_transform.origin.distance_to(player.global_transform.origin)
	# Normalize the distance so that 0.5 * max_distance is the minimum distance for light adjustment
	var min_distance = max_distance * min_distance_factor
	var distance_factor = clamp((player_distance - min_distance) / (max_distance - min_distance), 0.0, 1.0)
	
	# Lerp the omni_range based on both distance from center and player distance
	
	if player_distance > threshold:
		var angle_based_range = lerp(above_threshold_range_value, min_light_range, distance_from_center)
		self.omni_range = lerp(min_light_range, angle_based_range, distance_factor)
	else:
		var angle_based_range = lerp(max_light_range, min_light_range, distance_from_center)
		self.omni_range = lerp(min_light_range, angle_based_range, distance_factor)
		
		
	
