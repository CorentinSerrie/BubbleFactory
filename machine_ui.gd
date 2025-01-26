class_name MachineUi
extends Control

@export var validate_button: Button
@export var redo_button: Button
@export var next_button: Button
@export var strenght_slider: Slider
@export var angle_slider: Slider
@export var strenght_label: Label
@export var angle_label: Label
@export var type_option: OptionButton
@export var entrance_container: Control
@export var exit_container: Control
@export var redo_worker_bubble: Control

var machine: BubbleMachine


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


func _ready():
	visible = false
	strenght_slider.value_changed.connect(func(value): strenght_label.text = str(value))
	angle_slider.value_changed.connect(func(value): angle_label.text = str(value))
	type_option.item_selected.connect(
		func(value): 
			machine.current_type = value
			OnMachineTypeChanged()
	)
	pass

func OnBubblePositionChanged() -> void:
	match machine.current_position:
		BubblePosition.entrance:
			visible = true
			entrance_container.visible = true
			exit_container.visible = false
			redo_worker_bubble.visible = false
			OnMachineTypeChanged()
		BubblePosition.inside:
			visible = false
		BubblePosition.exit:
			var isShapeValid: bool = machine.IsShapeValid(machine.current_shape)
			visible = true
			entrance_container.visible = false
			exit_container.visible = true
			next_button.visible = isShapeValid
			redo_worker_bubble.visible = !isShapeValid
			OnMachineTypeChanged()
		BubblePosition.out:
			visible = false
		pass

func OnMachineTypeChanged() -> void:
	if(machine.current_position == BubblePosition.inside || machine.current_position == BubblePosition.out):
		return
	match machine.current_type:
		MachineType.SQUASH_STRETCH:
			angle_slider.min_value = -90
			angle_slider.max_value = 90
			angle_slider.value = 0
			strenght_slider.min_value = 0
			strenght_slider.max_value = 2
			strenght_slider.value = 1
			
			pass
		MachineType.RAVIOLI:
			angle_slider.min_value = -90
			angle_slider.max_value = 90
			angle_slider.value = 0
			strenght_slider.min_value = 0
			strenght_slider.max_value = 2
			strenght_slider.value = 1
			pass
		MachineType.STAR:
			angle_slider.min_value = 0
			angle_slider.max_value = 90
			angle_slider.value = 0
			strenght_slider.min_value = -1
			strenght_slider.max_value = 1
			strenght_slider.value = 0
			pass

	pass
