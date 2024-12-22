extends OmniLight3D

@export var player: CharacterBody3D
@export var volumetric_fog_energy = 15.0
@export var base_light_energy = 5.0
@export var min_light_energy = 0.0  # Minimum energy the light can reach when player is close
@export var max_distance = 20.0 # Distance at which light energy will be at its base value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the initial values for the light and volumetric fog
	self.light_energy = base_light_energy
	self.light_volumetric_fog_energy = volumetric_fog_energy

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player_distance = global_transform.origin.distance_to(player.global_transform.origin)
	print(player_distance)
	# Calculate the light energy based on player distance
	var energy_factor = clamp(player_distance / max_distance, 0.0, 1.0)
	self.light_energy = lerp(min_light_energy, base_light_energy, energy_factor)

	# Volumetric fog energy can remain constant (if needed) or you can adjust it similarly
	self.light_volumetric_fog_energy = volumetric_fog_energy
