extends Node2D

@export var button : Button
@export var machines : Array[BubbleMachine]
@export var bubble: SS2D_Shape
@export var camera: Camera2D

var camera_zoom: float = 0.95

var current_machine:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(OnButtonPressed)
	pass # Replace with function body.

func OnButtonPressed() -> void:
	EnterMachine(current_machine)

func ShapeValidated(_shape: SS2D_Shape) -> void:
	machines[current_machine].shape_validated.disconnect(ShapeValidated)

	current_machine +=1
	if(current_machine < machines.size()):
		EnterMachine(current_machine)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(bubble, "global_position:x", 1920, 3)
		tween.parallel()
		tween.tween_property(camera, "global_position", Vector2.ZERO, 1)
		tween.parallel()
		tween.tween_property(camera, "zoom", Vector2.ONE * 0.447, 1)


func EnterMachine(index: int) -> void:
	machines[index].EnterShape(bubble)
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", machines[index].camera_position.global_position, machines[index].slide_duration)
	tween.parallel()
	tween.tween_property(camera, "zoom", Vector2.ONE * 0.95, 1)
	machines[index].shape_validated.connect(ShapeValidated)
