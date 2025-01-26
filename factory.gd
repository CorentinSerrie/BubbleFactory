extends Node2D

@export var button : Button
@export var machines : Array[BubbleMachine]
@export var bubble: SS2D_Shape
@export var camera: Camera2D

@export var outro_panel: Control
@export var circle_center: Node2D
@export var circle_in: Polygon2D
@export var circle_out: Polygon2D

var camera_zoom: float = 0.95

var current_machine:int = 0

var circle_edge_count : int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	outro_panel.visible = false
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
		tween.tween_property(bubble, "global_position:x", 2500, 3)
		tween.parallel()
		tween.tween_property(camera, "global_position", Vector2.ZERO, 1)
		tween.parallel()
		tween.tween_property(camera, "zoom", Vector2.ONE * 0.447, 1)
		tween.tween_callback(func(): LaunchOutro())


func EnterMachine(index: int) -> void:
	machines[index].EnterShape(bubble)
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", machines[index].camera_position.global_position, machines[index].slide_duration)
	tween.parallel()
	tween.tween_property(camera, "zoom", Vector2.ONE * 0.95, 1)
	machines[index].shape_validated.connect(ShapeValidated)

func LaunchOutro() -> void:
	outro_panel.visible = true
	var bubble_one = bubble.duplicate()
	var bubble_two = bubble.duplicate()
	outro_panel.add_child(bubble_one)
	outro_panel.move_child(bubble_one, 1)
	circle_out.add_child(bubble_two)
	var radius = GetShapeRadius(bubble_one)
	UpdateCirclePolygons(radius)
	CenterShapeInOutro(bubble_one)
	CenterShapeInOutro(bubble_two)

func CenterShapeInOutro(shape: SS2D_Shape) -> void:
	machines[0]._CenterShape(shape)
	shape.global_position = circle_center.global_position

func GetShapeRadius(shape: SS2D_Shape) -> float:
	var total_radius : float = 0
	
	var tessellated_array: PackedVector2Array = shape.get_point_array().get_tessellated_points()

	for k in range(0, tessellated_array.size()-1):
		var point_1_k: Vector2 = tessellated_array[tessellated_array.size()-2]
		if(k > 0):
			point_1_k = tessellated_array[k-1]			
		var point_k: Vector2 = tessellated_array[k]
		var point_k_1: Vector2 = tessellated_array[k+1]
		
		var angle_before = point_1_k.angle_to(point_k)
		var angle_after = point_k.angle_to(point_k_1)
		var weight = ((angle_before + angle_after) / 2) / (2 * PI)
		total_radius += weight * point_k.length()
	return total_radius

func UpdateCirclePolygons(radius: float):
	var circle_in_array = circle_in.polygon
	var circle_out_array = circle_out.polygon

	circle_in_array.clear()
	circle_out_array.clear()

	for i in range(0,circle_edge_count):
		circle_in_array.append(Vector2.RIGHT.rotated(2 * PI * i/circle_edge_count) * radius)
		circle_out_array.append(Vector2.RIGHT.rotated(2*PI*i/circle_edge_count) * radius)
	
	circle_out_array.append(Vector2.RIGHT * radius)
	circle_out_array.append(Vector2.ONE * 5000)
	circle_out_array.append(Vector2(1,-1) * 5000)
	circle_out_array.append(Vector2(-1,-1)* 5000)
	circle_out_array.append(Vector2(-1,1)* 5000)
	circle_out_array.append(Vector2.ONE * 5000)
	
	circle_in.polygon = circle_in_array
	circle_out.polygon = circle_out_array

	circle_in.global_position = circle_center.global_position
	circle_out.global_position = circle_center.global_position
	pass
