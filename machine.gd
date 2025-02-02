class_name BubbleMachine
extends Node2D

@export var entrance_position : Node2D
@export var exit_position : Node2D
@export var inside_position : Node2D
@export var camera_position: Node2D
@export var machine_ui: Control

@export var slide_duration : float = 1
@export var animation_duration : float = 1.5
@export var bubble_max_size : int = 200
@export var animate_process: bool = true

@export var animated_shape: AnimatedSprite2D
@export var sound: AudioStreamPlayer
@export var particle: GPUParticles2D

var is_busy : bool = false
var current_shape : SS2D_Shape
var initial_polygon_array: PackedVector2Array
var initial_polygon_point_in: PackedVector2Array
var initial_polygon_point_out: PackedVector2Array
signal shape_validated(shape: SS2D_Shape)

enum BubblePosition {	
	entrance,
	inside,
	exit,
	out
}

enum MachineType {
	SQUASH_STRETCH,
	RAVIOLI,
	STAR
}

var current_position : BubblePosition = BubblePosition.out
var current_type : MachineType = MachineType.SQUASH_STRETCH

func _ready():
	if(particle != null):
		particle.emitting = false
	machine_ui.machine = self
	machine_ui.OnBubblePositionChanged()
	machine_ui.validate_button.pressed.connect(_OnValidatePressed)
	machine_ui.redo_button.pressed.connect(_OnRedoPressed)
	machine_ui.next_button.pressed.connect(_OnValidatePressed)

func _OnValidatePressed() -> void:
	if(is_busy):
		return

	match current_position:
		BubblePosition.entrance :
			_ProcessShape(current_shape)
		BubblePosition.exit:
			_ValidateShape(current_shape)
		_:
			return

func _OnRedoPressed() -> void:
	if(is_busy):
		return

	match current_position:
		BubblePosition.exit:
			_ResetToEntrance(current_shape)
		_:
			return

func EnterShape(shape : SS2D_Shape) -> void:
	current_shape = shape
	_SaveInitialShape(shape)
	_PrintShape(shape)
	var center:Vector2 = _FindShapeCenter(shape)
	_CenterShape(shape)
	shape.position += center
	var tween = get_tree().create_tween()
	tween.tween_property(shape, "global_position", entrance_position.global_position, slide_duration)
	tween.tween_callback(func(): _SetCurrentPosition(BubblePosition.entrance))
	pass

func _ResetToEntrance(shape: SS2D_Shape) -> void: 
	_SetCurrentPosition( BubblePosition.inside)

	var tween = get_tree().create_tween()
	if(animate_process):
		tween.tween_property(shape, "scale", Vector2.ZERO, slide_duration)
		tween.parallel()
	tween.tween_property(shape, "global_position", inside_position.global_position, slide_duration)
	tween.tween_callback((
		func ():
			if(particle != null):
				particle.emitting = true
			if(animated_shape != null):
				animated_shape.play()
			_ResetShape(shape)
	))
	tween.tween_interval(animation_duration)
	tween.tween_callback(
		func ():
			if(particle != null):
				particle.emitting = false
			sound.play()
			if(animated_shape != null):
				animated_shape.pause()
				animated_shape.set_frame_and_progress(0, 0.0)
	)
	if(animate_process):
		tween.tween_callback(
			func(): 
				var center_tween = get_tree().create_tween()
				for i in range(0,10):
					center_tween.tween_interval(slide_duration/10)
					center_tween.tween_callback(
						func(): 
							_CenterShape(shape)
							print(shape.global_position)
					)
		)
		tween.tween_property(shape, "scale", Vector2.ONE, slide_duration)
		tween.parallel()
	tween.tween_property(shape, "global_position", entrance_position.global_position, slide_duration)
	tween.tween_callback(
		func(): 
			_SetCurrentPosition(BubblePosition.entrance)
	)
	pass


func _ProcessShape(shape : SS2D_Shape) -> void:
	_SetCurrentPosition( BubblePosition.inside)


	var tween = get_tree().create_tween()
	if(animate_process):
		tween.tween_property(shape, "scale", Vector2.ZERO, slide_duration)
		tween.parallel()
	tween.tween_property(shape, "global_position", inside_position.global_position, slide_duration)
	tween.tween_callback((
		func ():
			sound.play()
			if(particle != null):
				particle.emitting = true
			if(animated_shape != null):
				animated_shape.play()
			match current_type:
				MachineType.SQUASH_STRETCH:
					_SquashStretch(shape, machine_ui.angle_slider.value, machine_ui.strenght_slider.value)
				MachineType.RAVIOLI:
					_Ravioli(shape, machine_ui.angle_slider.value, machine_ui.strenght_slider.value)
				MachineType.STAR:
					_StarShape(shape, machine_ui.angle_slider.value, machine_ui.strenght_slider.value)
				_:
					pass
	))
	tween.tween_interval(animation_duration)
	tween.tween_callback(
		func ():
			if(particle != null):
				particle.emitting = false
			if(animated_shape != null):
				animated_shape.pause()
				animated_shape.set_frame_and_progress(0, 0.0)
	)
	if(animate_process):
		tween.tween_callback(
			func(): 
				var center_tween = get_tree().create_tween()
				for i in range(0,10):
					center_tween.tween_interval(slide_duration/10)
					center_tween.tween_callback(
						func(): 
							_CenterShape(shape)
							print(shape.global_position)
					)
		)
		tween.tween_property(shape, "scale", Vector2.ONE, slide_duration)
		tween.parallel()
	tween.tween_property(shape, "global_position", exit_position.global_position, slide_duration)
	tween.tween_callback(
		func(): 
			_SetCurrentPosition(BubblePosition.exit)
	)
	pass


func IsShapeValid(shape: SS2D_Shape) -> bool:
	var points: PackedVector2Array = shape.get_point_array().get_tessellated_points()
	if points.size() < 3:
		return false
	# Produce the fill mesh
	var fill_tris: PackedInt32Array = Geometry2D.triangulate_polygon(points)
	if fill_tris.is_empty():
		return false

	return true

func _ValidateShape(shape : SS2D_Shape) -> void:
	_SetCurrentPosition(BubblePosition.out)
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

	_CenterShape(shape)	
	_ConstraintShape(shape)
	return

# angle : degrees [0,360[
# strength : ]0,2[, 0: squash totaly, 2 : stretch * 2
func _Ravioli(shape: SS2D_Shape, angle: float, strength: float) -> void:
	print("Ravioli, angle: " +str(angle)+ ", strength: " + str(strength))
	var center : Vector2 = _FindShapeCenter(shape)

	for i in shape._points._points:
		var point = shape._points._points[i]
		var angle_vector_x : Vector2 = Vector2.from_angle(deg_to_rad(angle))
		var angle_vector_y : Vector2 = angle_vector_x.rotated(PI/2)

		var delta_pos : Vector2 = point.position - center
		var proj_x : float = delta_pos.dot(angle_vector_x)
		var proj_y : float = delta_pos.dot(angle_vector_y)

		var val_x = proj_x * (1.5 * (1 + strength) / 2 - strength * 2*abs(proj_y)/bubble_max_size) 
		if(sign(val_x) != sign(proj_x)):
			val_x = -val_x

		print("projX: " +str(proj_x)+ ", projy: " + str(proj_y) + ", val_x: " + str(val_x))
		point.position = center + val_x * angle_vector_x + proj_y * angle_vector_y

	_CenterShape(shape)
	_ConstraintShape(shape)
	return

# angle : degrees [0,360[
# strength : ]-1,1[, 0: nothing, 1 : multiply angles by 2
func _StarShape(shape: SS2D_Shape, angle: float, strength: float) -> void:
	print("star, angle: " +str(angle)+ ", strength: " + str(strength))
	var center : Vector2 = _FindShapeCenter(shape)

	for i in shape._points._points:
		var point = shape._points._points[i]
		var angle_vector_x : Vector2 = Vector2.from_angle(deg_to_rad(angle))

		var delta_pos : Vector2 = point.position - center

		var angle_to_x = angle_vector_x.angle_to(delta_pos)

		var sin_plus = (1 + sin(4 * angle_to_x))/2

		delta_pos += delta_pos * sin_plus * strength
		point.position = center + delta_pos

	_CenterShape(shape)
	_ConstraintShape(shape)
	return

func _CenterShape(shape: SS2D_Shape) -> void:
	var center : Vector2 = _FindShapeCenter(shape)

	for i in shape._points._points:
		var point = shape._points._points[i]
		var delta_pos : Vector2 = point.position - center
		point.position = delta_pos


func _FindShapeCenter(shape: SS2D_Shape) -> Vector2:
	var center: Vector2 = Vector2.ZERO
	
	var tessellated_array: PackedVector2Array = shape.get_point_array().get_tessellated_points()

	for k in range(0, tessellated_array.size()-1):
		var point_k: Vector2 = tessellated_array[k]
		var point_k_1: Vector2 = tessellated_array[k+1]
		center.x += (point_k.x + point_k_1.x)*(point_k.x * point_k_1.y - (point_k_1.x * point_k.y))
		center.y += (point_k.y + point_k_1.y)*(point_k.x * point_k_1.y - (point_k_1.x * point_k.y))	

	center.x = center.x / (6*_GetShapeArea(shape))
	center.y = center.y / (6*_GetShapeArea(shape))
	return center

func _GetShapeArea(shape: SS2D_Shape) -> float:
	var area: float = 0
	
	var tessellated_array: PackedVector2Array = shape.get_point_array().get_tessellated_points()

	for k in range(0, tessellated_array.size()-1):
		var point_k: Vector2 = tessellated_array[k]
		var point_k_1: Vector2 = tessellated_array[k+1]
		area += point_k.x * point_k_1.y - point_k_1.x * point_k.y
	return area/2

func _SaveInitialShape(shape: SS2D_Shape) -> void:
	initial_polygon_array.clear()
	initial_polygon_point_in.clear()
	initial_polygon_point_out.clear()
	for i in shape._points._point_order:		
		var point = shape._points._points[i]
		initial_polygon_array.append(point.position)
		initial_polygon_point_in.append(point.point_in)
		initial_polygon_point_out.append(point.point_out)
	pass

func _ResetShape(shape: SS2D_Shape) -> void:
	_PrintShape(shape)

	for i in range(0, initial_polygon_array.size()):		
		var point = shape._points._points[shape._points._point_order[i]]
		point.position = initial_polygon_array[i]
		point.point_in = initial_polygon_point_in[i]
		point.point_out = initial_polygon_point_out[i]

	_PrintShape(shape)

func _GetPackedArray(shape: SS2D_Shape) -> PackedVector2Array:
	var array: PackedVector2Array = PackedVector2Array()

	for i in shape._points._point_order:
		var point = shape._points._points[i]
		array.append(Vector2(point.position.x, point.position.y))
	
	return array

func _PrintShape(shape: SS2D_Shape) -> void:	
	for i in shape._points._point_order:		
		var point = shape._points._points[i]
		print("i:" + str(i) + "  pos: " + str(point.position))

func _ConstraintShape(shape: SS2D_Shape) -> void:
	for i in shape._points._points:
		var point = shape._points._points[i]
		if(point.position.x > bubble_max_size):
			point.position.x = bubble_max_size
		if(point.position.x < -bubble_max_size):
			point.position.x = -bubble_max_size
		if(point.position.y > bubble_max_size):
			point.position.y = bubble_max_size
		if(point.position.y < -bubble_max_size):
			point.position.y = -bubble_max_size

	return

func _SetCurrentPosition(bubble_pos) -> void:
	current_position = bubble_pos
	if((current_position == BubblePosition.entrance || current_position == BubblePosition.exit) && name == "machine_2"):
		print("yay")
		animated_shape.set_frame_and_progress(0, 0.8)
	machine_ui.OnBubblePositionChanged()

	

#if a point has some point in/point out, make sure it doesn't break the shape
#func ClearShape(shape : SS2D_Shape) - > void:
