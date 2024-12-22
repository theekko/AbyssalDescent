extends StaticBody3D
@export var valve_1: StaticBody3D
@export var valve_2: StaticBody3D
@export var light_1: OmniLight3D
@export var light_2: OmniLight3D
@export var light_bulb_1: MeshInstance3D
@export var light_bulb_2: MeshInstance3D
@export var drill: MeshInstance3D
@export var collider: CollisionShape3D
@export var drill_sound: AudioStreamPlayer3D
@export var rock: StaticBody3D
@export var unspeakable_horror: RigidBody3D

var valve_1_activated: bool = false
var valve_2_activated: bool = false
var drill_sound_playing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	valve_1.valve_turned.connect(activate_valve_1)
	valve_2.valve_turned.connect(activate_valve_2)
	unspeakable_horror.visible = false
	unspeakable_horror.set_collision_layer(0)

func activate_valve_1():
	valve_1_activated = true
	light_1.light_color = Color(0.39, 0.89, 0, 1)
	var material = light_bulb_1.mesh.surface_get_material(0)
	material.emission = Color(0.39, 0.89, 0, 1)
	light_bulb_1.mesh.surface_set_material(0, material)
	print("valve_1_activated")

func activate_valve_2():
	valve_2_activated = true
	light_2.light_color = Color(0.39, 0.89, 0, 1)
	var material = light_bulb_2.mesh.surface_get_material(0)
	material.emission = Color(0.39, 0.89, 0, 1)
	light_bulb_2.mesh.surface_set_material(0, material)
	print("valve_2_activated")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if valve_1_activated and valve_2_activated:
		if drill_sound_playing == false:
			drill_sound.play()
			drill_sound_playing = true
		drill.visible = false
		collider.disabled = true
		rock.visible = false
		unspeakable_horror.visible = true
		unspeakable_horror.set_collision_layer(1 << 4)
