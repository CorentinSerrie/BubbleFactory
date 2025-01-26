extends TextureRect

@export var bubble_1: Control
@export var bubble_2: Control
@export var bubble_3: Control
@export var bubble_4: Control
@export var transition_screen: Control

@export var next_button: Control

@export var delay: float

@export var intro_sound: AudioStreamPlayer
@export var transition_sound: AudioStreamPlayer
@export var music: AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	intro_sound.play()
	bubble_2.visible = false
	bubble_3.visible = false
	bubble_4.visible = false
	next_button.visible = false

	next_button.pressed.connect(_Transition)

	var tween = get_tree().create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(func(): bubble_2.visible = true)
	tween.tween_interval(delay)
	tween.tween_callback(func(): bubble_3.visible = true)
	tween.tween_interval(delay)
	tween.tween_callback(func(): bubble_4.visible = true)
	tween.tween_interval(delay)
	tween.tween_callback(func(): next_button.visible = true)
	pass # Replace with function body.

func _Transition() -> void:
	transition_sound.play()
	transition_screen.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(transition_screen, "modulate:a", 1, 1)
	tween.tween_callback(
		func() : 
			self.visible = false
			music.play()
	)
	tween.tween_property(transition_screen, "modulate:a", 0, 1)
	tween.tween_callback(func() : transition_screen.visible = false)
