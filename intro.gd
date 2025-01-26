extends TextureRect

@export var bubble_1: Control
@export var bubble_2: Control
@export var bubble_3: Control
@export var bubble_4: Control

@export var next_button: Control

@export var delay: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bubble_2.visible = false
	bubble_3.visible = false
	bubble_4.visible = false
	next_button.visible = false

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
