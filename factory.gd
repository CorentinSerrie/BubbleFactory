extends Node2D

@export var button : Button
@export var machine_A : BubbleMachine
@export var bubble: SS2D_Shape




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(OnButtonPressed)
	pass # Replace with function body.

func OnButtonPressed() -> void:
	machine_A.EnterShape(bubble)