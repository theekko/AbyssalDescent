extends RigidBody3D

# Fish Movement
@export var move_speed = 3.0
@export var rotate_speed = 1.0  # Speed of rotation

#Waypoint inputs
@export var waypoints: Array[Node3D] = []  # List of waypoints
@export var angle_threshold = 0.99 

#Player interactions
@export var player: CharacterBody3D
@export var camera: Camera3D
@export var follow_threshold: float = 40.0  # Distance where fish starts following player
@export var stop_follow_threshold: float = 35.0  # Distance where fish stops following player


@export var open_mouth_distance: float = 20.0
@export var bite_distance: float = 10.0 

@export var ambient_audio_distance = 50
@export var ambient_interval: float = 8.0
@export var ambient_audio: AudioStreamPlayer3D
@export var open_mouth_audio: AudioStreamPlayer3D
@export var bite_audio: AudioStreamPlayer3D
var open_mouth_audio_playing =false
var bite_audio_playing = false
var ambient_timer = 0.0


#animation Player
var animation_player: AnimationPlayer
var current_waypoint_index: int = 0
var is_rotating: bool = false
var pause_timer: float = 0.0
var target_rotation: Basis
var is_moving: bool = false
var ray_cast: RayCast3D
var open_mouth_playing = false
var is_following_player = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if waypoints.size() > 0:
		print("Waypoints initialized.")
		move_to_next_waypoint()
		ray_cast = $RayCast3D
		animation_player = $AnimationPlayer
		if animation_player == null:
			print("AnimationPlayer is not assigned!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if waypoints.size() > 0:
		var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)

		if is_following_player:
			# Stop following if the player is out of the "stop follow" threshold
			if distance_to_player > stop_follow_threshold:
				is_following_player = false
				is_rotating = true  # Start rotating towards the next waypoint
				set_target_rotation()
			elif player_in_range():
				if is_fish_visible_to_camera():
					print("I see you")
					face_player(delta)
				else:
					follow_player(delta)
		else:
			# Start following if the player is within the "follow" threshold
			if distance_to_player <= follow_threshold :
				is_following_player = true
			elif is_rotating:
				rotate_towards_waypoint(delta)
			elif is_moving:
				move_towards_waypoint(delta)
			else:
				is_rotating = true
				set_target_rotation()

		# Check if the player is within bite distance
		if distance_to_player <= bite_distance:
			# Switch to Bite animation if the player is close
			if animation_player.current_animation != "Bite":
				animation_player.play("Bite")
				if not bite_audio_playing:
					bite_audio.play()
					bite_audio_playing = true
				open_mouth_playing = false
		elif distance_to_player <= open_mouth_distance:
			if not open_mouth_playing and is_fish_facing_player():
				print("opening_mouth")
				animation_player.play("OpenMouth")
				if not open_mouth_audio_playing:
					open_mouth_audio.play()
					open_mouth_audio_playing = true
				open_mouth_playing = true
		else:
			# Switch back to SwimSlow animation if the player is far away
			if animation_player.current_animation != "SwimSlow":
				animation_player.play("SwimSlow")
				open_mouth_playing = false
	
	if global_transform.origin.distance_to(player.global_transform.origin) <= ambient_audio_distance:
		ambient_timer += delta
		if ambient_timer >= ambient_interval:
			ambient_audio.play()
			ambient_timer = 0.0
		
func move_to_next_waypoint() -> void:
	is_moving = false

# Smoothly rotate towards the next waypoint
func rotate_towards_waypoint(delta: float) -> void:
	var current_rotation: Basis = global_transform.basis
	global_transform.basis = current_rotation.slerp(target_rotation, rotate_speed * delta)

	# Check if the rotation is close enough to the target (using dot product)
	var current_forward: Vector3 = current_rotation.z.normalized()  # Forward direction of the current rotation
	var target_forward: Vector3 = target_rotation.z.normalized()  # Forward direction of the target rotation
	
	# If the dot product is close to 1, consider the rotation finished
	if current_forward.dot(target_forward) > angle_threshold:  # Threshold for "close enough"
		is_rotating = false
		is_moving = true  # Start moving after rotation is complete

# Move towards the current waypoint
func move_towards_waypoint(delta: float) -> void:
	var target_waypoint: Node3D = waypoints[current_waypoint_index]

	# Rotate to face the target waypoint using the head node's position
	look_at(target_waypoint.global_transform.origin, Vector3.UP, true)

	# Move the object forward in its local +Z direction after rotation
	translate(Vector3.BACK * move_speed * delta)
	
	# Check if we've reached the waypoint
	if global_transform.origin.distance_to(target_waypoint.global_transform.origin) < 0.1:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
		move_to_next_waypoint()  # Start the next pause and rotation


# Set the target rotation to face the next waypoint
func set_target_rotation() -> void:
	var current_waypoint: Node3D = waypoints[current_waypoint_index]
	var direction: Vector3 = (current_waypoint.global_transform.origin - global_transform.origin).normalized()
	
	# Use look_at to get the correct target orientation
	var look_at_transform: Transform3D = Transform3D(global_transform.basis, global_transform.origin)
	look_at_transform = look_at_transform.looking_at(current_waypoint.global_transform.origin, Vector3.UP, true)
	
	# Set the target rotation basis
	target_rotation = look_at_transform.basis
	
func player_in_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) <= follow_threshold

func has_line_of_sight() -> bool:
	ray_cast.target_position = player.global_transform.origin - global_transform.origin
	ray_cast.force_raycast_update()
	
	return not ray_cast.is_colliding()
	
func follow_player(delta: float) -> void:
	look_at(player.global_transform.origin, Vector3.UP, true)
	translate(Vector3.BACK * move_speed * delta)
	
func face_player(delta: float) -> void:
	look_at(player.global_transform.origin, Vector3.UP, true)


func is_fish_visible_to_camera() -> bool:
	# Directly check if the fish's position is within the camera's frustum
	return camera.is_position_in_frustum(global_transform.origin)
	

func is_fish_facing_player() -> bool:
	var fish_forward = global_transform.basis.z.normalized()  # Assuming forward is -Z
	var to_player = (player.global_transform.origin - global_transform.origin).normalized()
	var dot = fish_forward.dot(to_player)
	return dot > 0.9  # Adjust threshold as needed
