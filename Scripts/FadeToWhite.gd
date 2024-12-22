extends CanvasLayer
@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
@onready var wait_timer = Timer.new()  # Create a Timer instance
var play_reverse = true

signal transition_complete

func _ready() -> void:
	color_rect.visible = false
	add_child(wait_timer)  # Add the timer to the scene
	wait_timer.one_shot = true  # Make sure the timer only triggers once
	wait_timer.timeout.connect(_on_wait_timer_timeout)  # Connect the timeout signal
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
	print("play reverse")
	if anim_name == "FadeToBlack":
		wait_timer.start(2.0)  # Wait for 2 seconds before transitioning back
	elif anim_name == "FadeToGame":
		color_rect.visible = false  # Hide the canvas after the animation
		emit_signal("transition_complete")

func _on_wait_timer_timeout():
	animation_player.play("FadeToGame")  # Play the reverse animation after the timer ends

func transition():
	print("play forward")
	color_rect.visible = true
	animation_player.play("FadeToBlack")
	play_reverse = true
