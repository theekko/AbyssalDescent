extends CharacterBody3D

signal turn_valve
signal flower_detected
signal flower_not_detected
signal unknown_horror_detected
signal unknown_horror_not_detected

var speed
var can_move = false
@export var menu: Control
@export var WALK_SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var SENSITIVITY = 0.005


# Bobbing variables
@export var BOB_FREQ = 2.0
@export var BOB_AMP = 0.08
@export var bob_time = 1.0

# FOV variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Holding Flower Status
@export var holding_flower = false
@export var flower: StaticBody3D

# Player Environment Interaction Raycast
@export var interaction_raycast: RayCast3D
@export var raycast_distance: float = -3
@export var digging: AudioStreamPlayer3D

# Fish interaction
@onready var interaction_area = $Area3D

# Paricle Emmiter
@export var bubbles_right: GPUParticles3D
@export var bubbles_left: GPUParticles3D
@export var emission_interval = 5.0  
@export var emission_duration = 1.0  
@export var inhale: AudioStreamPlayer3D
@export var bubbles: AudioStreamPlayer3D
var emission_timer = 0.0
var inhale_timer = 1.8
var bubbles_playing = false
var inhale_playing = false


var layer_map = {
	"Flowers": 1 << 1,  # Layer 2
	"Valves": 1 << 2,    # Layer 3
	"UnknownHorror": 1 << 4
}

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var reset_timer = $Timer
@onready var turn_timer = $TurnTimer

var mouse_capture = false
var player_start_position
var initial_head_rotation
var initial_camera_rotation
var flower_detected_bool = false
var unknown_horror_detected_bool = false

func _ready():
	TransitionToDark.transition_complete.connect(_on_transition_complete)
	turn_timer.timeout.connect(_on_turn_timer_timeout)
	player_start_position = self.global_transform
	initial_head_rotation = head.rotation  
	initial_camera_rotation = camera.rotation
	interaction_raycast.target_position = Vector3(0, 0, raycast_distance)
	flower.hide()
	bubbles_right.emitting = false
	bubbles_left.emitting = false
	interaction_area.body_entered.connect(_on_body_entered)

func _on_transition_complete():
	call_deferred("capture_mouse")  # Capture mouse after transition ends


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if can_move:
		# detect flower
		if interaction_raycast.is_colliding():
			if unknown_horror_detected_bool == false:
				_on_ray_hit()
				unknown_horror_detected_bool = true
			if flower_detected_bool == false:
				_on_ray_hit()
				flower_detected_bool = true
		else:
			if flower_detected_bool == true:
				emit_signal("flower_not_detected")
				flower_detected_bool = false
			if unknown_horror_detected_bool == true:
				emit_signal("unknown_horror_not_detected")
				unknown_horror_detected_bool = false
		
		# change mouse settings
		if Input.is_action_just_pressed("ui_cancel"):
			if mouse_capture == false:
				mouse_capture = true
			else:
				mouse_capture = false
		if mouse_capture == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		speed = WALK_SPEED
			
		# Get the input direction_horizontal for x and z axes
		var input_dir := Input.get_vector("left", "right", "forward", "back")
		var vertical_dir := 0.0
		if Input.is_action_pressed("up"):
			vertical_dir = 1.0
		elif Input.is_action_pressed("down"):
			vertical_dir = -1.0
		var direction_horizontal = (head.transform.basis * Vector3(input_dir.x, vertical_dir, input_dir.y)).normalized()
		var direction_vertical = (camera.transform.basis * Vector3(input_dir.x, vertical_dir, input_dir.y)).normalized()
		# Horizontal movement
		if (direction_horizontal != Vector3.ZERO or direction_vertical != Vector3.ZERO):
			velocity.x = direction_horizontal.x * speed
			velocity.y = direction_vertical.y * speed
			velocity.z = direction_horizontal.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.y = move_toward(velocity.y, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	
	## HEAD BOB
	if velocity.length() < 0.1:
		bob_time += delta 
		camera.transform.origin = _headbob(bob_time)
	else:
		bob_time = 0.0
	
	# INTERACTION INPUTS
	if Input.is_action_just_pressed("Interact"):
		_check_interact()
	
	if Input.is_action_just_pressed("Drop"):
		_despawn_flower()
	
	
	# BUBBLE EMISSION TIMER
	emission_timer += delta
	inhale_timer += delta
	if inhale_timer >= emission_interval and inhale_playing == false:
		inhale.play()
		inhale_playing = true;
	if emission_timer >= emission_interval:
		if bubbles_playing == false:
			bubbles.play()
			bubbles_right.emitting = true
			bubbles_left.emitting = true
			bubbles_playing = true
		
		if emission_timer >= emission_interval + emission_duration:
			bubbles_right.emitting = false
			bubbles_left.emitting = false
			bubbles_playing = false
			inhale_playing = false
			emission_timer = 0.0
			inhale_timer = 1.8
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	# Up and down bobbing (Y axis)
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	
	# Side-to-side bobbing (X axis)
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	# Forward and backward bobbing (Z axis)
	pos.z = sin(time * BOB_FREQ / 3) * BOB_AMP / 2  # Slower, smaller movement on the Z axis for subtlety
	
	return pos
	
# Function to check for interactions
func _check_interact() -> void:
	var collider = interaction_raycast.get_collider()
	if collider != null:
		var collision_layer = collider.get_collision_layer()

		# Check if collider is on the Flowers layer
		if collision_layer & layer_map["Flowers"]:
			_spawn_flower()
		elif collision_layer & layer_map["Valves"]:
			_turn_valve()
		elif collision_layer & layer_map["UnknownHorror"]:
			TransitionToLight.transition()
			reset_timer.start(2.0)
			reset_timer.timeout.connect(_reset_position_and_menu)
			
			
func _reset_position_and_menu():
	reset_timer.stop() 
	self.global_transform = player_start_position
	head.rotation = initial_head_rotation 
	camera.rotation = initial_camera_rotation 
	if menu.visible == false:
		menu.visible = true

func _on_body_entered(body):
	TransitionToDark.transition()
	self.global_transform = player_start_position
	head.rotation = initial_head_rotation 
	camera.rotation = initial_camera_rotation 
	call_deferred("capture_mouse")

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	


# Function to handle the interaction with the flower
func _spawn_flower() -> void:
	if not holding_flower:
		digging.play()
		holding_flower = true
		flower.show()
		
func _despawn_flower() -> void:
	if holding_flower:
		holding_flower = false
		flower.hide()

func _turn_valve() -> void:
	emit_signal("turn_valve")
	can_move = false  
	velocity = Vector3.ZERO 
	turn_timer.start(5.0)  
	
func _on_turn_timer_timeout():
	can_move = true

func _on_ray_hit() -> void:
	var collider = interaction_raycast.get_collider()
	if collider != null:
		var collision_layer = collider.get_collision_layer()

		# Check if the hit object is on the "Flowers" layer
		if collision_layer & layer_map["Flowers"]:
			emit_signal("flower_detected")  # Emit the signal when a flower is detected
			print("Flower detected in range")  # Optional debug message
		if collision_layer & layer_map["UnknownHorror"]:
			emit_signal("unknown_horror_detected")  # Emit the signal when a flower is detected
			print("Unkonwn Horror detected in range")  # Optional debug message
