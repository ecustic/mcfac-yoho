extends Node
class_name PlayerController

func _process(_delta: float) -> void:
	var viking: Viking = get_parent()

	if viking == null:
		return

	viking.move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var mouse_axis = (get_viewport().get_mouse_position() - viking.global_position)

	print("Mouse Axis: ", mouse_axis)
	if viking.animation_state_machine.get_current_node() != "Attack":
		viking.look_direction = mouse_axis.normalized()

func _input(event: InputEvent) -> void:
	var viking: Viking = get_parent();

	if event.is_action_released("attack") and viking.animation_state_machine.get_current_node() != "Attack":
		viking.animation_state_machine.start("Attack", true)
