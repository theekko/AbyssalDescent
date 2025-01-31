extends WorldEnvironment

@export var player: CharacterBody3D

# Fog settings
@export var max_fog_density: float = 0.1
@export var min_fog_density: float = 0.001

# Y position settings
@export var min_y_value: float = 0.0  # Below this value, fog density is max
@export var max_y_value: float = 60.0   # Above this value, fog density is min

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_fog_density()

func _update_fog_density() -> void:
	# Get the player's Y position
	var player_y = player.global_transform.origin.y

	# Calculate the interpolation factor based on the player's Y position
	var t = smoothstep(max_y_value, min_y_value, player_y)

	# Interpolate between min and max fog density
	var current_fog_density = lerp(min_fog_density, max_fog_density, t)
	self.environment.volumetric_fog_density = current_fog_density
