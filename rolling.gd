extends Sprite2D

@export var speed: float
@export var center: Node2D

func _ready():
	offset = global_position - center.global_position
	position = -offset
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += speed * delta
	pass
