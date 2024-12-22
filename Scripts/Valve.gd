extends StaticBody3D

@export var player: CharacterBody3D
@export var light_bulb: MeshInstance3D
@export var squeek: AudioStreamPlayer3D
@export var light_array: Array[OmniLight3D]
signal valve_turned

@onready var interaction_area = $Area3D
@onready var animation_player = $AnimationPlayer
var valve_turn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_body_entered(body):
	if body == player:
		print("in body")
		player.turn_valve.connect(turn_valve)

func _on_body_exited(body):
	if body == player:
		player.turn_valve.disconnect(turn_valve)


func turn_valve():
	if valve_turn == false:
		animation_player.play("TurnValve") 
		squeek.play()
		valve_turn = true
				# Start the timer to stop the audio after a specific time
		var timer = Timer.new()
		timer.wait_time = 5.1
		timer.one_shot = true
		timer.timeout.connect(_on_stop_squeek)
		add_child(timer)
		timer.start()

# This function is called when the timer times out
func _on_stop_squeek() -> void:
	squeek.stop()  # Stop the audio after the set duration

func _on_animation_finished(anim_name):
	if anim_name == "TurnValve":
		emit_signal("valve_turned")
		for light in light_array:
			light.light_color = Color(0.39, 0.89, 0, 1)
		var material = light_bulb.mesh.surface_get_material(0)
		material.emission = Color(0.39, 0.89, 0, 1)
		light_bulb.mesh.surface_set_material(0, material)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
