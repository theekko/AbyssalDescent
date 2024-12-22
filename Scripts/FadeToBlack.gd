extends CanvasLayer
signal transition_complete

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
var play_reverse = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
	print("play reverse")
	if anim_name == "FadeToBlack":
		animation_player.play("FadeToGame")  # Play the animation in reverse
	elif anim_name == "FadeToGame":
		color_rect.visible = false  # Hide the canvas after the animation
		emit_signal("transition_complete")
	
func transition():
	print("play forward")
	color_rect.visible = true
	animation_player.play("FadeToBlack")
	play_reverse = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
