class_name Machine
extends Node2D


@export var input_shape: SS2D_Shape
@export var button: Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(OnButtonPressed)
	pass # Replace with function body.

func OnButtonPressed() -> void:
	ScoreShape(input_shape)

func Flatten() -> void:
	var center: Vector2 = Vector2.ZERO
	var point_count: int = 0
	for i in input_shape._points._points:
		var point = input_shape._points._points[i]
		print(point.position.x)
		print(point.position.y)
		center += point.position
		point_count += 1

	center.x = center.x / point_count
	center.y = center.y / point_count
	print(center)

	for i in input_shape._points._points:
		var point = input_shape._points._points[i]
		point.position.x = center.x + (point.position.x - center.x) / 2
		print(point.position.x)
		print(point.position.y)


func ScoreShape(shape: SS2D_Shape) -> float:
	var approximate_polygon = Polygon2D.new()

	var polygon_array: PackedVector2Array = approximate_polygon.polygon

	for i in shape._points._point_order:
		var point = shape._points._points[i]
		polygon_array.append(Vector2(point.position.x, point.position.y))

	approximate_polygon.polygon = polygon_array
	print(findPolygonCenter(approximate_polygon))
	print(FindShapeCenter(shape))
	GetShapeVSPolygonArea(shape, approximate_polygon)

	polygon_array.clear()
	for i in shape._points._point_order:
		var point = shape._points._points[i]
		polygon_array.append(Vector2(point.position.x, point.position.y) - findPolygonCenter(approximate_polygon))
		
	approximate_polygon.polygon = polygon_array

	add_child(approximate_polygon)
	

	return 0

func GetShapeVSPolygonArea(shape: SS2D_Shape, polygon: Polygon2D) -> void:
	var shape_area: float = 0
	for k in range(0, shape._points._point_order.size()-1):
		var a:int = shape._points._point_order[k]
		var b:int = shape._points._point_order[k+1]
		shape_area += shape._points._points[a].position.x * shape._points._points[b].position.y - shape._points._points[b].position.x * shape._points._points[a].position.y
		print("i: " + str(a) + "   point: " + str(shape._points._points[a].position) + "   area: " + str(shape_area))

	var area: float = 0
	for i in range(0, polygon.polygon.size() - 1):
		area += polygon.polygon[i].x * polygon.polygon[i+1].y - polygon.polygon[i+1].x * polygon.polygon[i].y
		print("i: " + str(i) + "   point: " + str(polygon.polygon[i]) + "   area: " + str(area))

	area += polygon.polygon[polygon.polygon.size() - 1].x * polygon.polygon[0].y - polygon.polygon[0].x * polygon.polygon[polygon.polygon.size() - 1].y
	print("i: " + str(polygon.polygon.size() - 1) + "   point: " + str(polygon.polygon[polygon.polygon.size() - 1]) + "   area: " + str(area))



func FindShapeCenter(shape: SS2D_Shape) -> Vector2:
	var center: Vector2 = Vector2.ZERO
	
	for k in range(0, shape._points._point_order.size()-1):
		var a:int = shape._points._point_order[k]
		var b:int = shape._points._point_order[k+1]
		center.x += (shape._points._points[a].position.x + shape._points._points[b].position.x)*(shape._points._points[a].position.x * shape._points._points[b].position.y - (shape._points._points[b].position.x * shape._points._points[a].position.y))
		center.y += (shape._points._points[a].position.y + shape._points._points[b].position.y)*(shape._points._points[a].position.x * shape._points._points[b].position.y - (shape._points._points[b].position.x * shape._points._points[a].position.y))

	center.x = center.x / (6*GetShapeArea(shape))
	center.y = center.y / (6*GetShapeArea(shape))
	return center

func GetShapeArea(shape: SS2D_Shape) -> float:
	var area: float = 0
	
	for k in range(0, shape._points._point_order.size()-1):
		var a:int = shape._points._point_order[k]
		var b:int = shape._points._point_order[k+1]
		area += shape._points._points[a].position.x * shape._points._points[b].position.y - shape._points._points[b].position.x * shape._points._points[a].position.y
	return area/2

func findPolygonCenter(polygon: Polygon2D) -> Vector2:
	var center: Vector2 = Vector2.ZERO
	
	for i in range(0, polygon.polygon.size() - 1):
		center.x += (polygon.polygon[i].x + polygon.polygon[i+1].x)*((polygon.polygon[i].x * polygon.polygon[i+1].y) - (polygon.polygon[i+1].x * polygon.polygon[i].y))
		center.y += (polygon.polygon[i].y + polygon.polygon[i+1].y)*((polygon.polygon[i].x * polygon.polygon[i+1].y) - (polygon.polygon[i+1].x * polygon.polygon[i].y))
	
	var i = polygon.polygon.size() - 1
	center.x += (polygon.polygon[i].x + polygon.polygon[0].x)*((polygon.polygon[i].x * polygon.polygon[0].y) - (polygon.polygon[0].x * polygon.polygon[i].y))
	center.y += (polygon.polygon[i].y + polygon.polygon[0].y)*((polygon.polygon[i].x * polygon.polygon[0].y) - (polygon.polygon[0].x * polygon.polygon[i].y))

	center.x = center.x / (6*GetPolygonArea(polygon))
	center.y = center.y / (6*GetPolygonArea(polygon))
	return center


func GetPolygonArea(polygon: Polygon2D) -> float:
	var area: float = 0
	for i in range(0, polygon.polygon.size() - 1):
		area += polygon.polygon[i].x * polygon.polygon[i+1].y - polygon.polygon[i+1].x * polygon.polygon[i].y

	area += polygon.polygon[polygon.polygon.size() - 1].x * polygon.polygon[0].y - polygon.polygon[0].x * polygon.polygon[polygon.polygon.size() - 1].y
	return area/2

func FindCenterMean(shape: SS2D_Shape) -> Vector2:
	var center: Vector2 = Vector2.ZERO
	var point_count: int = 0
	for i in shape._points._points:
		center += shape._points._points[i].position
		point_count += 1

	center.x = center.x / point_count
	center.y = center.y / point_count
	return center