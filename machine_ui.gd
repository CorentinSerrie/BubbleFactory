class_name MachineUi
extends Control

@export var validate_button: Button
@export var redo_button: Button
@export var strenght_slider: Slider
@export var angle_slider: Slider
@export var strenght_label: Label
@export var angle_label: Label
@export var ravioli_slider: Slider
@export var ravioli_label: Label
@export var type_option: OptionButton

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
	strenght_slider.value_changed.connect(func(value): strenght_label.text = "strength: " + str(value))
	angle_slider.value_changed.connect(func(value): angle_label.text = "angle: " + str(value))
	ravioli_slider.value_changed.connect(func(value): ravioli_label.text = "angle: " + str(value))
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
			_HideAll()
			validate_button.visible = true
			OnMachineTypeChanged()
		BubblePosition.inside:
			visible = true
			_HideAll()
		BubblePosition.exit:
			visible = true
			_HideAll()
			validate_button.visible = true
			redo_button.visible = true
			OnMachineTypeChanged()
		BubblePosition.out:
			visible = false
		pass

func OnMachineTypeChanged() -> void:
	if(machine.current_position == BubblePosition.inside || machine.current_position == BubblePosition.out):
		return
	match machine.current_type:
		MachineType.SQUASH_STRETCH:
			strenght_slider.visible = true
			angle_slider.visible = true
			strenght_label.visible = true
			angle_label.visible = true
			ravioli_slider.visible = false
			ravioli_label.visible = false
			pass
		MachineType.RAVIOLI:
			strenght_slider.visible = false
			angle_slider.visible = false
			strenght_label.visible = false
			angle_label.visible = false
			ravioli_slider.visible = true
			ravioli_label.visible = true
		MachineType.STAR:
			strenght_slider.visible = false
			angle_slider.visible = false
			strenght_label.visible = false
			angle_label.visible = false
			ravioli_slider.visible = false
			ravioli_label.visible = false
			pass

	pass


func _HideAll() -> void:
	validate_button.visible = false
	redo_button.visible = false
	strenght_slider.visible = false
	angle_slider.visible = false
	strenght_label.visible = false
	angle_label.visible = false
	ravioli_slider.visible = false
	ravioli_label.visible = false