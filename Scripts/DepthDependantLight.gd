extends DirectionalLight3D

@export var player: CharacterBody3D

# Fog settings
@export var max_light_energy: float = 1
@export var min_light_energy: float = 0.05

# Y position settings
@export var min_y_value: float = 0.0  # Below this value, fog density is max
@export var max_y_value: float = 60.0   # Above this value, fog density is min

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_light_energy()

func _update_light_energy() -> void:
	# Get the player's Y position
	var player_y = player.global_transform.origin.y

	# Calculate the interpolation factor based on the player's Y position
	var t = smoothstep(max_y_value, min_y_value, player_y)
	# Interpolate between min and max fog density
	var current_light_energy = lerp(max_light_energy, min_light_energy, t)

	# Apply the fog density to the environment

	self.light_energy = current_light_energy
