extends Control

@onready var skill_tree_container: Control = %SkillTreeContainer
@onready var skill_tree_button_container: Control = %SkillTreeButtonContainer
@onready var xp_label: Label = %XPLabel

func _ready() -> void:
	GameManager.viking_state.state_changed.connect(_on_viking_state_changed)
	_on_viking_state_changed()

func _on_viking_state_changed() -> void:
	xp_label.text = str(GameManager.viking_state.current_xp)


func _on_start_button_pressed() -> void:
	GameManager.start_game()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_skill_tree_button_pressed() -> void:
	show_skill_tree()

func show_skill_tree():
	pass


func _on_skill_button_editor_state_changed() -> void:
	pass # Replace with function body.


func _on_skills_button_pressed() -> void:
	if skill_tree_container.visible:
		skill_tree_container.hide()
	else:
		skill_tree_container.show()
		xp_label.text = str(GameManager.viking_state.current_xp)
		for skill_button in skill_tree_button_container.get_children():
			if skill_button is SkillButton:
				skill_button.render_skill()
		
	
