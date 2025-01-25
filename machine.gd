class_name BubbleMachine
extends Node2D

@export var entrance_position : Node2D
@export var exit_position : Node2D
@export var camera_position: Node2D
@export var machine_ui: Control

@export var slide_duration : float = 1

enum shape_position{
	entrance,
	inside,
	exit,
	out
}

var is_busy : bool = false
var current_shape : SS2D_Shape
signal shape_validated(shape: SS2D_Shape)

var current_position : shape_position = shape_position.out

func _ready():
	machine_ui.visible = false
	machine_ui.validate_button.pressed.connect(_OnValidatePressed)
	machine_ui.redo_button.pressed.connect(_OnRedoPressed)
	machine_ui.strenght_slider.value_changed.connect(func (value): machine_ui.strenght_label.text = "strength: " + str(value))
	machine_ui.angle_slider.value_changed.connect(func (value): machine_ui.angle_label.text = "angle: " + str(value))

func _OnValidatePressed() -> void:
	if(is_busy):
		return

	match current_position:
		shape_position.entrance :
			_ProcessShape(current_shape)
		shape_position.exit:
			_ValidateShape(current_shape)
		_:
			return

func _OnRedoPressed() -> void:
	if(is_busy):
		return

	match current_position:
		shape_position.exit:
			_ProcessShape(current_shape)
		_:
			return

func EnterShape(shape : SS2D_Shape) -> void:
	machine_ui.visible = true
	current_position = shape_position.entrance
	current_shape = shape
	var tween = get_tree().create_tween()
	tween.tween_property(shape, "global_position", entrance_position.global_position, slide_duration)
	pass

func _ProcessShape(shape : SS2D_Shape) -> void:
	current_position = shape_position.inside
	var tween = get_tree().create_tween()
	tween.tween_property(shape, "global_position", global_position, slide_duration)
	tween.tween_callback(func (): _SquashStretch(shape, machine_ui.angle_slider.value, machine_ui.strenght_slider.value))
	tween.tween_interval(1)
	tween.tween_property(shape, "global_position", exit_position.global_position, slide_duration)
	tween.tween_callback(func(): current_position = shape_position.exit)
	pass

func _ValidateShape(shape : SS2D_Shape) -> void:	
	machine_ui.visible = false
	current_position = shape_position.out
	shape_validated.emit(shape)
	current_shape = null
	pass

# angle : degrees [0,360[
# strength : ]0,2[, 0: squash totaly, 2 : stretch * 2
func _SquashStretch(shape: SS2D_Shape, angle: float, strength: float) -> void:
	print("squash stretch, angle: " +str(angle)+ ", strength: " + str(strength))
	var center : Vector2 = _FindShapeCenter(shape)

	for i in shape._points._points:
		var point = shape._points._points[i]
		var angle_vector_x : Vector2 = Vector2.from_angle(deg_to_rad(angle))
		var angle_vector_y : Vector2 = angle_vector_x.rotated(PI/2)

		var delta_post : Vector2 = point.position - center
		point.position = center + delta_post.dot(angle_vector_x) * strength * angle_vector_x + delta_post.dot(angle_vector_y) * angle_vector_y

	return

func _FindShapeCenter(shape: SS2D_Shape) -> Vector2:
	var center: Vector2 = Vector2.ZERO
	
	for k in range(0, shape._points._point_order.size()-1):
		var a:int = shape._points._point_order[k]
		var b:int = shape._points._point_order[k+1]
		center.x += (shape._points._points[a].position.x + shape._points._points[b].position.x)*(shape._points._points[a].position.x * shape._points._points[b].position.y - (shape._points._points[b].position.x * shape._points._points[a].position.y))
		center.y += (shape._points._points[a].position.y + shape._points._points[b].position.y)*(shape._points._points[a].position.x * shape._points._points[b].position.y - (shape._points._points[b].position.x * shape._points._points[a].position.y))

	center.x = center.x / (6*_GetShapeArea(shape))
	center.y = center.y / (6*_GetShapeArea(shape))
	return center

func _GetShapeArea(shape: SS2D_Shape) -> float:
	var area: float = 0
	
	for k in range(0, shape._points._point_order.size()-1):
		var a:int = shape._points._point_order[k]
		var b:int = shape._points._point_order[k+1]
		area += shape._points._points[a].position.x * shape._points._points[b].position.y - shape._points._points[b].position.x * shape._points._points[a].position.y
	return area/2

#if a point has some point in/point out, make sure it doesn't break the shape
#func ClearShape(shape : SS2D_Shape) - > void:
