extends Control



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_skills_pressed() -> void:
	get_tree().change_scene_to_file("res://skill_tree/skill_tree.tscn")


func _on_exit_game_pressed() -> void:
	get_tree().quit()
