extends Control



func _on_start_button_pressed() -> void:
	GameManager.start_game()



func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_skill_tree_button_pressed() -> void:
	show_skill_tree()

func show_skill_tree():
	pass
